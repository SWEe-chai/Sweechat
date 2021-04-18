import FirebaseFirestore
import os

/**
 A utility class that queries the Firebase connection for `UserModulePair`s.
 */
class FirebaseUserModulePairQuery {
    /// Retrieves the `UserModulePair` with the specified module ID and user ID,
    /// and executes the specified function on completion.
    /// - Parameters:
    ///   - moduleId: The specified module ID.
    ///   - userId: The specified user ID.
    ///   - onCompletion: The specified function to run on completion.
    static func getUserModulePair(moduleId: Identifier<Module>,
                                  userId: Identifier<User>,
                                  onCompletion: @escaping (FirebaseUserModulePair?) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.userModulePairs)
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId.val)
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId.val)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }

                let pair: FirebaseUserModulePair? = FirebaseUserModulePairAdapter.convert(document: document)

                onCompletion(pair)
            }
    }
}
