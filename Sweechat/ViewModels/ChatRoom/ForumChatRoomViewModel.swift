import Combine
import Foundation

class ForumChatRoomViewModel: ChatRoomViewModel {
    var forumChatRoom: ForumChatRoom
    var forumSubscribers: [AnyCancellable] = []

    @Published var postViewModels: [MessageViewModel] = []
    @Published var replyViewModels: [MessageViewModel] = []
    var threadViewModel: ThreadViewModel!
    private var prominentThreadId: String?
    private var threadCreator: ForumViewModelDelegate?

    init(forumChatRoom: ForumChatRoom, delegate: ForumViewModelDelegate) {
        self.forumChatRoom = forumChatRoom
        self.threadCreator = delegate
        super.init(chatRoom: forumChatRoom, user: forumChatRoom.currentUser)
        initialiseForumSubscribers()
    }

    private func initialiseForumSubscribers() {
        let postsSubscriber = forumChatRoom.subscribeToPosts { posts in
            self.postViewModels = posts.compactMap {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   delegate: self,
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
        }

        let postIdToRepliesSubscriber = forumChatRoom.subscribeToReplies { replies in
            self.replyViewModels = replies.compactMap {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   delegate: self,
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
            self.updateThread(messages: replies)
        }

        forumSubscribers.append(postsSubscriber)
        forumSubscribers.append(postIdToRepliesSubscriber)
    }

    override func handleSendMessage(_ text: String, withParentId parentId: String?) {
        let id = UUID().uuidString
        // TODO: Slight fear, what if the message is persisted before the message. Other people get the message and try
        // to query for the chat room and the chat room has not been created?
        threadCreator?.createThreadChatRoom(id: id, currentUser: user, forumMembers: forumChatRoom.members)

        let message = Message(
            senderId: user.id,
            content: text.toData(),
            type: MessageType.text,
            receiverId: ChatRoom.allUsersId,
            parentId: parentId, id: id)
        self.chatRoom.storeMessage(message: message)
    }

    private func updateThread(messages: [Message]) {
        guard let postId = prominentThreadId,
              let postViewModel = postViewModels.first(where: { $0.id == postId }) else {
            return
        }
        threadViewModel = ThreadViewModel(
            post: postViewModel,
            replies: replyViewModels.filter { $0.parentId == postId }
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
