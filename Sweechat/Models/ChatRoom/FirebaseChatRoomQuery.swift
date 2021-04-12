import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseChatRoomQuery {
    static func getChatRoom(chatRoomId: Identifier<ChatRoom>,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        FirebaseUserChatRoomModulePairQuery
            .getUserChatRoomModulePair(chatRoomId: chatRoomId, userId: user.id.val) { pair in
                guard let pair = pair else {
                    return
                }
                getChatRoom(pair: pair, user: user) { chatRoom in
                    onCompletion(chatRoom)
                }
            }
    }
    static func getChatRoom(pair: FirebaseUserChatRoomModulePair,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        getChatRooms(pairs: [pair], user: user) { chatRooms in
            guard let chatRoom = chatRooms.first else {
                return
            }
            onCompletion(chatRoom)
        }
    }
    static func getChatRooms(pairs: [FirebaseUserChatRoomModulePair],
                             user: User,
                             onCompletion: @escaping ([ChatRoom]) -> Void) {
        let chatRoomIdStrs = pairs.map { $0.chatRoomId.val }
        if chatRoomIdStrs.isEmpty {
            onCompletion([])
            return
        }
        for chatRoomIdStrChunk in chatRoomIdStrs.chunked(into: 10) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.chatRooms)
                .whereField(DatabaseConstant.ChatRoom.id, in: chatRoomIdStrChunk)
                .getDocuments { snapshots, error in
                    guard let documents = snapshots?.documents else {
                        os_log("Getting chatrooms: ChatRooms with Id: \(chatRoomIdStrChunk) does not exist")
                        os_log("Error \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    let chatRooms: [ChatRoom] = documents.compactMap { document in
                        guard let chatRoomIdStr = document[DatabaseConstant.ChatRoom.id] as? String,
                              let pair = pairs.first(where: { $0.chatRoomId.val == chatRoomIdStr }) else {
                            os_log("ChatRoomQuery: Unable extract chatRoomId from \(document) or pair not in \(pairs)")
                            return nil
                        }
                        return FirebaseChatRoomFacade.convert(
                            document: document,
                            user: user,
                            withPermissions: pair.permissions)
                    }
                    onCompletion(chatRooms)
                }
        }
    }
}
