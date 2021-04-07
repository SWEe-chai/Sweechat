import FirebaseFirestore
import os

class FirebaseUserModulePairQuery {
    static func getUserModulePair(moduleId: String,
                                  userId: String,
                                  onCompletion: @escaping (FirebaseUserModulePair?) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.userModulePairs)
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId)
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let pair: FirebaseUserModulePair? = FirebaseUserModulePairFacade.convert(document: document)
                onCompletion(pair)
            }
    }
}
