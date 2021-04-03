import Combine

class ForumChatRoomViewModel: ChatRoomViewModel {
    var forumChatRoom: ForumChatRoom
    var forumSubscribers: [AnyCancellable] = []

    @Published var postViewModels: [MessageViewModel] = []
    @Published var postIdToReplyViewModel: [String: [MessageViewModel]] = [:]
    @Published var isThreadOpen: Bool = false
    var threadViewModel: ThreadViewModel!
    private var prominentThreadId: String?

    init(forumChatRoom: ForumChatRoom) {
        self.forumChatRoom = forumChatRoom
        super.init(chatRoom: forumChatRoom, user: forumChatRoom.currentUser)
        initialiseForumSubscribers()
    }

    private func initialiseForumSubscribers() {
        let postsSubscriber = forumChatRoom.subscribeToPosts { posts in
            self.postViewModels = posts.map {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
        }
        let postIdToRepliesSubscriber = forumChatRoom.subscribeToMessages { messages in
            self.updateThread(messages: messages)
        }

        forumSubscribers.append(postsSubscriber)
        forumSubscribers.append(postIdToRepliesSubscriber)
    }

    private func updateThread(messages: [Message]) {
        guard let postId = prominentThreadId,
              let postViewModel = postViewModels.first(where: { $0.id == postId }) else {
            return
        }
        threadViewModel = ThreadViewModel(
            post: postViewModel,
            replies: messages
                .filter({ $0.parentId == prominentThreadId })
                .map({ MessageViewModelFactory
                        .makeViewModel(
                            message: $0,
                            sender: forumChatRoom.getUser(userId: user.id),
                            isSenderCurrentUser: user.id == $0.senderId) })
        )
    }

    func setThread(_ postViewModel: MessageViewModel) {
        prominentThreadId = postViewModel.id
        threadViewModel = ThreadViewModel(
            post: postViewModel,
            replies: messages.filter({ $0.parentId == prominentThreadId })
        )
    }
}
