class ForumChatRoomViewModel: ChatRoomViewModel {
    var forumChatRoom: ForumChatRoom
    init(forumChatRoom: ForumChatRoom) {
        self.forumChatRoom = forumChatRoom
        super.init(chatRoom: forumChatRoom, user: forumChatRoom.currentUser)
    }
}
