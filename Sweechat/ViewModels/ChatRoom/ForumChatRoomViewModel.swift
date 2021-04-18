import Combine
import Foundation
import os

class ForumChatRoomViewModel: ChatRoomViewModel {
    private let forumChatRoom: ForumChatRoom
    private var forumSubscribers: [AnyCancellable] = []
    private var prominentThreadId: String?
    private var threadCreator: ThreadCreator?

    @Published var postViewModels: [MessageViewModel] = []
    @Published var threadViewModels: [ThreadChatRoomViewModel] = []

    // MARK: Initialization

    init(forumChatRoom: ForumChatRoom, creator: ThreadCreator) {
        self.forumChatRoom = forumChatRoom
        self.threadCreator = creator
        super.init(chatRoom: forumChatRoom, user: forumChatRoom.currentUser)
        initialiseForumSubscribers()
    }

    // MARK: SendMessageHandler

    override func handleSendText(_ text: String,
                                 withParentMessageViewModel parentMessageViewModel: MessageViewModel?) {
        let parentId = IdentifierConverter.toOptionalMessageId(from: parentMessageViewModel?.parentId)
        let messageId = Identifier<Message>(val: UUID().uuidString)
        let chatRoomId = Identifier<ChatRoom>(val: messageId.val)

        threadCreator?.createThreadChatRoom(id: chatRoomId, currentUser: user, forumMembers: forumChatRoom.members) {
            self.chatRoom.storeMessage(message: Message(
                                        senderId: self.user.id,
                                        content: text.toData(),
                                        type: MessageType.text,
                                        receiverId: ChatRoom.allUsersId,
                                        parentId: parentId,
                                        id: messageId))
        }
    }

    // MARK: Threads

    func setThread(_ postViewModel: MessageViewModel) {
        prominentThreadId = postViewModel.id
    }

    func getSelectedThread() -> ThreadChatRoomViewModel {
        guard let threadChatRoomVM = threadViewModels.first(where: { $0.id == prominentThreadId }) else {
            fatalError("Thread is selected but no thread is set as prominent thread. Please contact our dev team.")
        }

        return threadChatRoomVM
    }

    // MARK: Private Helper Methods

    private func initialiseForumSubscribers() {
        let postsSubscriber = forumChatRoom.subscribeToMessages { postIdsToPosts in
            self.updateThreadViewModels(withPostIdsToPosts: postIdsToPosts)
            self.updatePostViewModels(withPostIdsToPosts: postIdsToPosts)
        }

        forumSubscribers.append(postsSubscriber)
    }

    private func updateThreadViewModels(withPostIdsToPosts postIdsToPosts: [Identifier<Message>: Message]) {
        let currentPostIds = Set(self.postViewModels.map { $0.id })
        let newPosts = postIdsToPosts.values.filter { !currentPostIds.contains($0.id.val) }

        self.threadViewModels.append(contentsOf: newPosts.compactMap {
            let post = TextMessageViewModel(message: $0,
                                            sender: self.chatRoom.getUser(userId: $0.senderId),
                                            currentUserId: self.user.id)
            post.delegate = self
            return ThreadChatRoomViewModel(post: post, user: self.forumChatRoom.currentUser)
        })
        self.threadViewModels.sort { $0.post.creationTime < $1.post.creationTime }
    }

    private func updatePostViewModels(withPostIdsToPosts postIdsToPosts: [Identifier<Message>: Message]) {
        self.postViewModels = postIdsToPosts.values.compactMap {
            MessageViewModelFactory.makeViewModel(message: $0,
                                                  sender: self.chatRoom.getUser(userId: $0.senderId),
                                                  delegate: self,
                                                  currentUserId: self.user.id)
        }
    }
}
