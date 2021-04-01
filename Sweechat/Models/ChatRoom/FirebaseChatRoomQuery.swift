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
}
