class ThreadChatRoomViewModel: ChatRoomViewModel {
    private var threadChatRoom: ThreadChatRoom

    init(threadChatRoom: ThreadChatRoom) {
        self.threadChatRoom = threadChatRoom
        super.init(chatRoom: threadChatRoom, user: threadChatRoom.currentUser)
    }
}
