class GroupChatRoom: ChatRoom {

    override init(id: String,
                  name: String,
                  currentUser: User,
                  permissions: ChatRoomPermissionBitmask,
                  members: [User] = [],
                  profilePictureUrl: String? = nil) {
        super.init(id: id,
                   name: name,
                   currentUser: currentUser,
                   permissions: permissions,
                   members: members,
                   profilePictureUrl: profilePictureUrl)
    }
}
