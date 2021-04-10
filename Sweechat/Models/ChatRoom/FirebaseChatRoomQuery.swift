import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseChatRoomQuery {
    static func getChatRoom(chatRoomId: String,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        FirebaseUserChatRoomModulePairQuery
            .getUserChatRoomModulePair(chatRoomId: chatRoomId, userId: user.id) { pair in
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
        let chatRoomIds = pairs.map { $0.chatRoomId }
        if chatRoomIds.isEmpty {
            onCompletion([])
            return
        }
        for chatRoomIdChunk in chatRoomIds.chunked(into: 10) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.chatRooms)
                .whereField(DatabaseConstant.ChatRoom.id, in: chatRoomIdChunk)
                .getDocuments { snapshots, error in
                    guard let documents = snapshots?.documents else {
                        os_log("Getting chatrooms: ChatRooms with Id: \(chatRoomIdChunk) does not exist")
                        os_log("Error \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    let chatRooms: [ChatRoom] = documents.compactMap { document in
                        guard let chatRoomId = document[DatabaseConstant.ChatRoom.id] as? String,
                              let pair = pairs.first(where: { $0.chatRoomId == chatRoomId }) else {
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
