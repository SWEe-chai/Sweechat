import FirebaseFirestore
import os

/**
 An adapter for translating between `FirebaseUserModulePair` and its Firebase representation.
 */
struct FirebaseUserModulePairAdapter {
    /// Converts the specified Firebase document into a `FirebaseUserModulePair`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    /// - Returns: A `FirebaseUserModulePair` based on the specified Firebase document,
    ///            or nil if the conversion fails.
    static func convert(document: DocumentSnapshot) -> FirebaseUserModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userIdStr = data?[DatabaseConstant.UserModulePair.userId] as? String,
              let moduleIdStr = data?[DatabaseConstant.UserModulePair.moduleId] as? String,
              let permissions = data?[DatabaseConstant.UserModulePair.permissions] as? ModulePermissionBitmask else {
            os_log("Error converting data for UserModulePair, data: %s", String(describing: data))
            return nil
        }

        let userId = Identifier<User>(val: userIdStr)
        let moduleId = Identifier<Module>(val: moduleIdStr)
        return FirebaseUserModulePair(userId: userId, moduleId: moduleId, permissions: permissions)
    }

    /// Converts the specified `FirebaseUserModulePair` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - pair: The specified `FirebaseUserModulePair`.
    /// - Returns: A Firebase compatible dictionary based on the specified `FirebaseUserModulePair`.
    static func convert(pair: FirebaseUserModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserModulePair.userId: pair.userId.val,
            DatabaseConstant.UserModulePair.moduleId: pair.moduleId.val,
            DatabaseConstant.UserModulePair.permissions: pair.permissions
        ]
    }
}
