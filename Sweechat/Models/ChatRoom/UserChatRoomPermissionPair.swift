/**
 Represents a `User` and his/her associated `ChatRoom` permissions.
 */
struct UserChatRoomPermissionPair {
    let userId: Identifier<User>
    let permissions: ChatRoomPermissionBitmask
}
