class GroupChatRoom: ChatRoom {

    override init(id: String,
                  name: String,
                  currentUser: User,
                  profilePictureUrl: String? = nil) {
        super.init(id: id,
                   name: name,
                   currentUser: currentUser,
                   profilePictureUrl: profilePictureUrl)
    }

    override init(name: String,
                  members: [User],
                  currentUser: User,
                  profilePictureUrl: String? = nil) {
        super.init(name: name,
                   members: members,
                   currentUser: currentUser,
                   profilePictureUrl: profilePictureUrl)
    }
}
