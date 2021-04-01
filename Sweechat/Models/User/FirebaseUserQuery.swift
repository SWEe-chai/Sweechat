import FirebaseFirestore
import os

class FirebaseUserQuery {
    static func getUser(withId id: String, onCompletion: @escaping (User) -> Void) {
        getUsers(withIds: [id]) { users in
            guard let user = users.first else {
                return
            }
            onCompletion(user)
        }
    }

    static func getUsers(withIds ids: [String],
                         onCompletion: @escaping ([User]) -> Void) {
        if ids.isEmpty {
            onCompletion([])
            return
        }
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.users)
            .whereField(DatabaseConstant.User.id, in: ids)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let users: [User] = documents.compactMap {
                    FirebaseUserFacade.convert(document: $0)
                }
                onCompletion(users)
            }
    }
}
