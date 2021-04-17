import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseChatRoomQuery {
    static func getChatRoom(chatRoomId: Identifier<ChatRoom>,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        FirebaseUserChatRoomModulePairQuery.getUserChatRoomModulePair(chatRoomId: chatRoomId, userId: user.id) { pair in
            if let pair = pair {
                getChatRoom(pair: pair, user: user) { chatRoom in
                    onCompletion(chatRoom)
                }
            }
        }
    }

    static func getChatRoom(pair: FirebaseUserChatRoomModulePair,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        getChatRooms(pairs: [pair], user: user) { chatRooms in
            if let chatRoom = chatRooms.first {
                onCompletion(chatRoom)
            }
        }
    }

    static func getChatRooms(pairs: [FirebaseUserChatRoomModulePair],
                             user: User,
                             onCompletion: @escaping ([ChatRoom]) -> Void) {
        let chatRoomIdStrings = pairs.map { $0.chatRoomId.val }

        if chatRoomIdStrings.isEmpty {
            onCompletion([])
            return
        }

        for chatRoomIdStringsChunk in chatRoomIdStrings.chunked(into: FirebaseUtils.queryChunkSize) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.chatRooms)
                .whereField(DatabaseConstant.ChatRoom.id, in: chatRoomIdStringsChunk)
                .getDocuments { snapshots, error in
                    guard let documents = snapshots?.documents else {
                        os_log("Getting chatrooms: ChatRooms with ID: \(chatRoomIdStringsChunk) does not exist")
                        os_log("Error getting chatrooms (\(error?.localizedDescription ?? ""))")
                        return
                    }

                    let chatRooms: [ChatRoom] = documents.compactMap { document in
                        guard let chatRoomIdStr = document[DatabaseConstant.ChatRoom.id] as? String,
                              let pair = pairs.first(where: { $0.chatRoomId.val == chatRoomIdStr }) else {
                            os_log("ChatRoomQuery: Unable extract chatRoomId from \(document) or pair not in \(pairs)")
                            return nil
                        }

                        return FirebaseChatRoomAdapter.convert(
                            document: document,
                            user: user,
                            withPermissions: pair.permissions)
                    }

                    onCompletion(chatRooms)
                }
        }
    }
}
