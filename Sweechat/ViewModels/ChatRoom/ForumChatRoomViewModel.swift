import Combine
import Foundation
import os

class ForumChatRoomViewModel: ChatRoomViewModel {
    var forumChatRoom: ForumChatRoom
    var forumSubscribers: [AnyCancellable] = []

    @Published var postViewModels: [MessageViewModel] = []
    @Published private var threads: [ThreadChatRoomViewModel] = []
    var threadId: ThreadViewModel!
    private var prominentThreadId: String?
    private var threadCreator: ThreadCreator?

    init(forumChatRoom: ForumChatRoom, creator: ThreadCreator) {
        self.forumChatRoom = forumChatRoom
        self.threadCreator = creator
        super.init(chatRoom: forumChatRoom, user: forumChatRoom.currentUser)
        initialiseForumSubscribers()
    }

    private func initialiseForumSubscribers() {
        let postsSubscriber = forumChatRoom.subscribeToMessages { posts in
            let updatedPostIds = Set(posts.map({ $0.id.val }))
            self.postViewModels = self.postViewModels.filter({ updatedPostIds.contains($0.id) })
            let currentPostsIds = Set(self.postViewModels.map { $0.id })
            let newPosts = posts.filter { !currentPostsIds.contains($0.id.val) }
            self.threads.append(contentsOf: newPosts.compactMap {
                ThreadChatRoomViewModel(post: $0,
                                        postSender: self.chatRoom.getUser(userId: $0.senderId),
                                        user: self.forumChatRoom.currentUser)
            })
            self.postViewModels.append(contentsOf: newPosts.compactMap {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   delegate: self,
                                   currentUserId: self.user.id)
            })
        }

        forumSubscribers.append(postsSubscriber)
    }

    override func handleSendMessage(_ text: String, withParentId parentId: String?) {
        let id = Identifier<Message>(val: UUID().uuidString)
        // TODO: Change this to Identifier<ChatRoom>
        threadCreator?.createThreadChatRoom(id: id.val, currentUser: user, forumMembers: forumChatRoom.members) {
            let message = Message(
                senderId: self.user.id,
                content: text.toData(),
                type: MessageType.text,
                receiverId: ChatRoom.allUsersId,
                parentId: parentId, id: id)
            self.chatRoom.storeMessage(message: message)
        }
    }

    func setThread(_ postViewModel: MessageViewModel) {
        prominentThreadId = postViewModel.id
    }

    func getSelectedThread() -> ThreadChatRoomViewModel {
        guard let threadChatRoomVM = threads.first(where: { $0.id == prominentThreadId }) else {
            fatalError("Thread is selected but no thread is set as prominent thread. Please contact our dev team.")
        }
        return threadChatRoomVM
    }
}
