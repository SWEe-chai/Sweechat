class ThreadChatRoomViewModel: ChatRoomViewModel {
    override var id: String {
        threadChatRoom.id.val
    }
    private var threadChatRoom: ThreadChatRoom

    var post: MessageViewModel

    init(post: Message, postSender: User, user: User) {
        // TODO: Use PostMessage ID as the ID of the ChatRoom
        let chatRoomId: Identifier<ChatRoom> = Identifier(val: post.id.val)
        self.threadChatRoom = ThreadChatRoom(id: chatRoomId, ownerId: post.senderId, currentUser: user)
        self.post = TextMessageViewModel(
            message: post,
            sender: postSender,
            currentUserId: user.id)
        super.init(chatRoom: threadChatRoom, user: user)
        threadChatRoom.setChatRoomConnection()
    }
}
