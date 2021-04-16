class ThreadChatRoomViewModel: ChatRoomViewModel {
    private var threadChatRoom: ThreadChatRoom

    var post: MessageViewModel

    var mostPopularMessage: MessageViewModel? {
        guard let mostPopularMessage = threadChatRoom.mostPopularMessage else {
            return nil
        }

        return MessageViewModelFactory.makeViewModel(message: mostPopularMessage,
                                                     sender: self.chatRoom.getUser(userId: mostPopularMessage.senderId),
                                                     delegate: self,
                                                     currentUserId: self.user.id)
    }

    init(post: MessageViewModel, user: User) {
        // TODO: Use PostMessage ID as the ID of the ChatRoom
        let chatRoomId: Identifier<ChatRoom> = Identifier(val: post.message.id.val)
        self.threadChatRoom = ThreadChatRoom(id: chatRoomId, ownerId: post.message.senderId, currentUser: user)
        self.post = post
        super.init(chatRoom: threadChatRoom, user: user)
        threadChatRoom.setChatRoomConnection()
    }
}

extension ThreadChatRoomViewModel: Hashable {
    static func == (lhs: ThreadChatRoomViewModel, rhs: ThreadChatRoomViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
