import FirebaseFirestore
import os

/**
 A utility class that queries the Firebase connection for `User`s.
 */
class FirebaseUserQuery {
    /// Retrieves the `User` with the specified ID and executes the specified function on completion.
    /// - Parameters:
    ///   - id: The specified user ID.
    ///   - onCompletion: The specified function to run on completion.
    static func getUser(withId id: Identifier<User>, onCompletion: @escaping (User) -> Void) {
        getUsers(withIds: [id]) { users in
            if let user = users.first {
                onCompletion(user)
            }
        }
    }

    /// Retrieves the `User`s with the specified IDs and executes the specified function on completion.
    /// - Parameters:
    ///   - ids: The specified user IDs.
    ///   - onCompletion: The specified function to run on completion.
    static func getUsers(withIds ids: [Identifier<User>],
                         onCompletion: @escaping ([User]) -> Void) {
        if ids.isEmpty {
            onCompletion([])
            return
        }

        for idStringsChunk in ids.map({ $0.val }).chunked(into: FirebaseUtils.queryChunkSize) {
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
