import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseChatRoomQuery {
    static func getChatRoom(pair: FirebaseUserChatRoomModulePair,
                            user: User,
                            onCompletion: @escaping (ChatRoom) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(pair.chatRoomId)
            .getDocument { snapshot, error in
                guard let document = snapshot else {
                    os_log("Getting chatroom: ChatRoom with Id: \(pair.chatRoomId) does not exist")
                    os_log("Error \(error?.localizedDescription ?? "No error")")
                    return
                }
                guard let chatRoom = FirebaseChatRoomFacade
                        .convert(document: document,
                                 user: user,
                                 withPermissions: pair.permissions) else {
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
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.chatRooms)
            .whereField(DatabaseConstant.ChatRoom.id, in: chatRoomIds)
            .getDocuments { snapshots, error in
                guard let documents = snapshots?.documents else {
                    os_log("Getting chatrooms: ChatRooms with Id: \(chatRoomIds) does not exist")
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
