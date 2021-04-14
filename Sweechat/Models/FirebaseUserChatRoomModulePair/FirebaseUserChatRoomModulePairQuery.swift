import FirebaseFirestore
import os

class FirebaseUserChatRoomModulePairQuery {
    static func getUserChatRoomModulePairs(
        inChatRoomId chatRoomId: Identifier<ChatRoom>,
        onCompletion: @escaping ([FirebaseUserChatRoomModulePair]) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection
                            .userChatRoomModulePairs)
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId.val)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let pairs: [FirebaseUserChatRoomModulePair] = documents.compactMap {
                    FirebaseUserChatRoomModulePairFacade
                        .convert(document: $0)
                }
                onCompletion(pairs)
            }
    }
    static func getUserChatRoomModulePair(chatRoomId: Identifier<ChatRoom>,
                                          userId: Identifier<User>,
                                          onCompletion: @escaping (FirebaseUserChatRoomModulePair?) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId.val)
            .whereField(DatabaseConstant.UserChatRoomModulePair.userId, isEqualTo: userId.val)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let pair: FirebaseUserChatRoomModulePair? = FirebaseUserChatRoomModulePairFacade
                    .convert(document: document)
                onCompletion(pair)
            }
    }
}