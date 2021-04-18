/**
 Represents a `User` and his/her associated `ChatRoom` permissions for Firebase storage.
 */
class FirebaseUserChatRoomModulePair {
    let userId: Identifier<User>
    let chatRoomId: Identifier<ChatRoom>
    let moduleId: Identifier<Module>
    let permissions: ChatRoomPermissionBitmask

    /// Constructs a `FirebaseUserChatRoomModulePair` with the specified information.
    init(userId: Identifier<User>, chatRoomId: Identifier<ChatRoom>, moduleId: Identifier<Module>,
         permissions: ChatRoomPermissionBitmask) {
        self.userId = userId
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
