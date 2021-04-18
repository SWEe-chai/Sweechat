import FirebaseFirestore
import os

/**
 An adapter for translating between `Module` and its Firebase representation.
 */
struct FirebaseModuleAdapter {
    /// Converts the specified Firebase document, `User`, and permissions into a `Module`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    ///   - user: The specified `User`.
    ///   - permissions: The specified permissions.
    /// - Returns: A `Module` based on the specified Firebase document, or nil if the conversion fails.
    static func convert(document: DocumentSnapshot,
                        user: User,
                        withPermissions permissions: ModulePermissionBitmask) -> Module? {
        if !document.exists {
            os_log("Error: Cannot convert module, module document does not exist")
            return nil
        }
        let data = document.data()
        guard let idStr = data?[DatabaseConstant.Module.id] as? String,
              let name = data?[DatabaseConstant.Module.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for Module, data: %s", String(describing: data))
            return nil
        }

        let id = Identifier<Module>(val: idStr)
        return Module(
            id: id,
            name: name,
            currentUser: user,
            currentUserPermission: permissions,
            profilePictureUrl: profilePictureUrl
        )
    }

    /// Converts the specified `Module` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - message: The specified `Module`.
    /// - Returns: A Firebase compatible dictionary based on the specified `Module`.
    static func convert(module: Module) -> [String: Any] {
        [
            DatabaseConstant.Module.id: module.id.val,
            DatabaseConstant.Module.name: module.name,
            DatabaseConstant.Module.profilePictureUrl: module.profilePictureUrl ?? ""
        ]
    }
}
