import FirebaseFirestore
import os

class FirebaseUserChatRoomModulePairQuery {
    static func getUserChatRoomModulePair(chatRoomId: String,
                                          userId: String,
                                          onCompletion: @escaping (FirebaseUserChatRoomModulePair?) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId)
            .whereField(DatabaseConstant.UserChatRoomModulePair.userId, isEqualTo: userId)
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
