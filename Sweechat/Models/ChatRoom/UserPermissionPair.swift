/**
 Represents a `User` and his/her associated `ChatRoom` permissions.
 */
struct UserPermissionPair {
    let userId: Identifier<User>
    let permissions: ChatRoomPermissionBitmask
}
