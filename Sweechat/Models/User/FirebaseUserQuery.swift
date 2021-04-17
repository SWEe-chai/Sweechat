import FirebaseFirestore
import os

class FirebaseUserQuery {
    static func getUser(withId id: Identifier<User>, onCompletion: @escaping (User) -> Void) {
        getUsers(withIds: [id]) { users in
            if let user = users.first {
                onCompletion(user)
            }
        }
    }

    static func getUsers(withIds ids: [Identifier<User>],
                         onCompletion: @escaping ([User]) -> Void) {
        if ids.isEmpty {
            onCompletion([])
            return
        }

        for idStringsChunk in ids.map({ $0.val }).chunked(into: 10) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.users)
                .whereField(DatabaseConstant.User.id, in: idStringsChunk)
                .getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else {
                        os_log("Error listening for channel updates (\(error?.localizedDescription ?? ""))")
                        return
                    }
                    let users: [User] = documents.compactMap {
                        FirebaseUserAdapter.convert(document: $0)
                    }
                    onCompletion(users)
                }
        }
    }
}
