import Combine
import Foundation
import os

class ForumChatRoomViewModel: ChatRoomViewModel {
    var forumChatRoom: ForumChatRoom
    var forumSubscribers: [AnyCancellable] = []

    @Published var postViewModels: [MessageViewModel] = []
    @Published var replyViewModels: [MessageViewModel] = []
    @Published private var threads: [ThreadChatRoomViewModel] = []
    var threadId: ThreadViewModel!
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
            let currentPostsIds = Set(self.postViewModels.map { $0.id })
            let newPosts = posts.filter { !currentPostsIds.contains($0.id) }
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
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            })
            // TODO: When delete is implemented we should also get postIds of deleted messages and update
        }

        let postIdToRepliesSubscriber = forumChatRoom.subscribeToReplies { replies in
            self.replyViewModels = replies.compactMap {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   delegate: self,
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
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

    func setThread(_ postViewModel: MessageViewModel) {
        prominentThreadId = postViewModel.id
    }

    func getSelectedThread() -> ThreadChatRoomViewModel {
        guard let threadChatRoomVM = threads.first(where: { $0.id == prominentThreadId }) else {
            os_log("Thread is selected but no thread is set as prominent thread. Please contact our dev team.")
            fatalError()
        }
        return threadChatRoomVM
    }
}
