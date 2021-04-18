/**
 Represents a `User` and his/her associated `Module` permissions.
 */
struct UserModulePermissionPair {
    let userId: Identifier<User>
    let permissions: ModulePermissionBitmask
}
