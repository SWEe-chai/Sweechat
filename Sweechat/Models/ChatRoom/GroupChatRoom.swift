class GroupChatRoom: ChatRoom {
    override init(id: String, name: String, profilePictureUrl: String? = nil) {
        super.init(id: id, name: name, profilePictureUrl: profilePictureUrl)
    }

    override init(name: String, members: [User], profilePictureUrl: String? = nil) {
        super.init(name: name, members: members, profilePictureUrl: profilePictureUrl)
    }
}
