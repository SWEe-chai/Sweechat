import FirebaseFirestore
import os

/**
 An adapter for translating between `User` and its Firebase representation.
 */
struct FirebaseUserAdapter {
    /// Converts the specified Firebase document into a `User`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    /// - Returns: A `User` based on the specified Firebase document.
    static func convert(document: DocumentSnapshot) -> User {
        if !document.exists {
            os_log("Error: Cannot convert user, user document does not exist")
            return User.createUnavailableInstance()
        }
        let data = document.data()
        guard let idStr = data?[DatabaseConstant.User.id] as? String,
              let name = data?[DatabaseConstant.User.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for User, data: %s", String(describing: data))
            return User.createUnavailableInstance()
        }

        let id = Identifier<User>(val: idStr)
        return User(
            id: id,
            name: name,
            profilePictureUrl: profilePictureUrl
        )
    }

    /// Converts the specified `User` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - user: The specified `User`.
    /// - Returns: A Firebase compatible dictionary based on the specified `User`.
    static func convert(user: User) -> [String: Any] {
        [
            DatabaseConstant.User.id: user.id.val,
            DatabaseConstant.User.name: user.name,
            DatabaseConstant.User.profilePictureUrl: user.profilePictureUrl ?? ""
        ]
    }

    /// Converts the specified user ID and public key bundle data into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - userId: The specified user ID.
    ///   - publicKeyBundleData: The specified public key bundle data.
    /// - Returns: A Firebase compatible dictionary based on the specified user ID and key bundle data.
    static func convert(userId: Identifier<User>, publicKeyBundleData: Data) -> [String: Any] {
        [
            DatabaseConstant.PublicKeyBundle.userId: userId.val,
            DatabaseConstant.PublicKeyBundle.bundleData: publicKeyBundleData
        ]
    }
}
