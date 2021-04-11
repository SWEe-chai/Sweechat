class ThreadChatRoomViewModel: ChatRoomViewModel {
    var id: String {
        threadChatRoom.id
    }
    private var threadChatRoom: ThreadChatRoom

    var post: MessageViewModel

    init(post: Message, postSender: User, user: User) {
        self.threadChatRoom = ThreadChatRoom(id: post.id, ownerId: post.senderId, currentUser: user)
        self.post = TextMessageViewModel(
            message: post,
            sender: postSender,
            currentUserId: user.id)
        super.init(chatRoom: threadChatRoom, user: user)
        threadChatRoom.setChatRoomConnection()
    }
}
