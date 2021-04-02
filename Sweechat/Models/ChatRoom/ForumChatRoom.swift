class ForumChatRoom: ChatRoom {
    override init(id: String,
                  name: String,
                  currentUser: User,
                  currentUserPermission: ChatRoomPermissionBitmask,
                  profilePictureUrl: String? = nil) {
        assert(ChatRoomPermission.canRead(permission: currentUserPermission)
                && ChatRoomPermission.canWrite(permission: currentUserPermission),
               "Assertion failed, forum user cannot read write")
        super.init(id: id,
                   name: name,
                   currentUser: currentUser,
                   currentUserPermission: currentUserPermission,
                   profilePictureUrl: profilePictureUrl)
    }

    init(name: String,
         members: [User],
         currentUser: User,
         profilePictureUrl: String? = nil) {
        super.init(name: name,
                   members: members,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.all, // Creator gets all permissions
                   profilePictureUrl: profilePictureUrl)
    }
}
