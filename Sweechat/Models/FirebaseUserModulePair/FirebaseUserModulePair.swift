/**
 Represents a `User` and his/her associated `Module` permissions for Firebase storage.
 */
class FirebaseUserModulePair {
    let userId: Identifier<User>
    let moduleId: Identifier<Module>
    let permissions: ModulePermissionBitmask

    init(userId: Identifier<User>, moduleId: Identifier<Module>, permissions: ModulePermissionBitmask) {
        self.userId = userId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
