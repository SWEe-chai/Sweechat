class PrivateChatRoom: ChatRoom {
    var otherUser: User?
    override init(id: String, name: String, profilePictureUrl: String? = nil) {
        super.init(id: id, name: "", profilePictureUrl: profilePictureUrl)
    }

    override init(name: String, members: [User], profilePictureUrl: String? = nil) {
        super.init(name: "", members: members, profilePictureUrl: profilePictureUrl)
    }
}
