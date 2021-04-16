import Combine
import SwiftUI
import FirebaseStorage
import os

class ChatRoomViewModel: ObservableObject, SendMessageHandler {
    var chatRoom: ChatRoom
    var user: User
    private var chatRoomMediaCache: ChatRoomMediaCache
    private var subscribers: [AnyCancellable] = []
    weak var delegate: ChatRoomViewModelDelegate?

    @Published var latestMessageViewModel: MessageViewModel?
    @Published var text: String
    @Published var profilePictureUrl: String?
    @Published var areAllMessagesLoaded: Bool = false

    var permissions: ChatRoomViewModelType {
        ChatRoomViewModelType.convert(permission: chatRoom.currentUserPermission)
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var isStarred: Bool {
        chatRoom.isStarred
    }

    var id: String {
        chatRoom.id.val
    }

    @Published var messages: [MessageViewModel] = []

    static func createUnavailableInstance() -> ChatRoomViewModel {
        GroupChatRoomViewModel(
            groupChatRoom: ChatRoom.createUnavailableInstance()
        )
    }
    @Published var earlyLoadedMessages: [MessageViewModel] = []

    init(chatRoom: ChatRoom, user: User) {
        self.chatRoom = chatRoom
        self.user = user
        self.text = chatRoom.name
        self.profilePictureUrl = chatRoom.profilePictureUrl
        self.chatRoomMediaCache = ChatRoomMediaCache(chatRoomId: chatRoom.id)
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        let messagesSubscriber = chatRoom.subscribeToMessages { messages in
            let allMessageIds = Set<Identifier<Message>>(messages.map({ $0.id }))

            // Deletion
            self.messages = self.messages.filter({ allMessageIds.contains(Identifier<Message>(stringLiteral: $0.id)) })

            // Insertion
            let oldMessageIds = Set<Identifier<Message>>(self.messages.map {
                Identifier<Message>(stringLiteral: $0.id)
            })
            let newMessageIds = allMessageIds.filter({ !oldMessageIds.contains($0) })
            let newMessages = messages.filter({ newMessageIds.contains($0.id) })
            let newMessageViewModels = self.generateViewModels(from: newMessages)
            for newMessageViewModel in newMessageViewModels {
                newMessageViewModel.delegate = self
            }
            self.messages.append(contentsOf: newMessageViewModels)
            self.messages.sort(by: { $0.message.creationTime < $1.message.creationTime })
            self.latestMessageViewModel = self.messages.last
        }
        let earlyMessagesSubscriber = chatRoom.subscribeToEarlyLoadedMessages { messages in
            self.earlyLoadedMessages = self.generateViewModels(from: messages)
        }
        let chatRoomNameSubscriber = chatRoom.subscribeToName { newName in
            self.text = newName
        }
        let allMessagesLoadedSubscriber = chatRoom.subscribeToAreAllMessagesLoaded { self.areAllMessagesLoaded = $0
        }

        let profilePictureSubscriber = chatRoom.subscribeToProfilePicture { profilePictureUrl in
            self.profilePictureUrl = profilePictureUrl
        }

        subscribers.append(messagesSubscriber)
        subscribers.append(chatRoomNameSubscriber)
        subscribers.append(earlyMessagesSubscriber)
        subscribers.append(allMessagesLoadedSubscriber)
        subscribers.append(profilePictureSubscriber)
    }

    func handleChatRoomAppearance() {
        self.delegate?.terminateNotificationResponse()
    }

    func loadMore() {
        chatRoom.loadMore()
    }

    func loadUntil(messageViewModel: MessageViewModel) {
        chatRoom.loadUntil(message: messageViewModel.message)
    }

    func getMessageViewModel(withId id: String?) -> MessageViewModel? {
        guard let messageId = id else {
            return nil
        }
        if let message = messages.first(where: { $0.id == messageId }) {
            return message
        }
        return earlyLoadedMessages.first { $0.id == messageId }
    }

    // MARK: SendMessageHandler
    func handleSendText(_ text: String,
                        withParentMessageViewModel parentMessageViewModel: MessageViewModel?) {
        let parentId = IdentifierConverter.toOptionalMessageId(from: parentMessageViewModel?.parentId)
        let message = Message(senderId: user.id, content: text.toData(), type: MessageType.text,
                              receiverId: ChatRoom.allUsersId, parentId: parentId)
        self.chatRoom.storeMessage(message: message)
    }

    func handleEditText(_ text: String,
                        withEditedMessageViewModel editedMessageViewModel: MessageViewModel?) {
        guard let editedMessageViewModel = editedMessageViewModel else {
            os_log("handleEditText called when MessageViewModel is nil")
            return
        }
        editedMessageViewModel.message.content = text.toData()
        self.chatRoom.storeMessage(message: editedMessageViewModel.message)
    }

    func handleSendImage(_ wrappedImage: Any?,
                         withParentMessageViewModel parentMessageViewModel: MessageViewModel?) {
        guard let image = wrappedImage as? UIImage else {
            os_log("wrappedImage is not UIImage")
            return
        }

        guard let data = image.jpegData(compressionQuality: 0.05) else {
            os_log("unable to get jpeg data for image")
            return
        }

        let parentId = IdentifierConverter.toOptionalMessageId(from: parentMessageViewModel?.parentId)
        self.chatRoom.uploadToStorage(data: data, fileName: "\(UUID().uuidString).jpg") { url in
            let urlstring = url.absoluteString
            let message = Message(senderId: self.user.id, content: urlstring.toData(), type: MessageType.image,
                                  receiverId: ChatRoom.allUsersId, parentId: parentId)
            self.chatRoom.storeMessage(message: message)
        }
    }

    func handleSendVideo(_ mediaURL: Any?,
                         withParentMessageViewModel parentMessageViewModel: MessageViewModel?) {
        guard let url = mediaURL as? URL else {
            os_log("media url is not a url")
            print("media url: \(String(describing: mediaURL))")
            return
        }

        let parentId = IdentifierConverter.toOptionalMessageId(from: parentMessageViewModel?.parentId)
        do {
            let data = try Data(contentsOf: url)
            self.chatRoom.uploadToStorage(data: data, fileName: "\(UUID().uuidString).MOV") { url in
                let urlstring = url.absoluteString
                let message = Message(senderId: self.user.id, content: urlstring.toData(), type: MessageType.video,
                                      receiverId: ChatRoom.allUsersId, parentId: parentId)
                self.chatRoom.storeMessage(message: message)
            }
        } catch {
            os_log("failed to convert data: \(error.localizedDescription)")
            return
        }
    }

    private func generateViewModels<S: Sequence>(from messages: S)
            -> [MessageViewModel] where S.Iterator.Element == Message {
        messages.compactMap {
            MessageViewModelFactory
                .makeViewModel(
                    message: $0,
                    sender: self.chatRoom.getUser(userId: $0.senderId),
                    delegate: self,
                    currentUserId: self.user.id)
        }
    }
}

// MARK: MediaMessageViewModelDelegate
extension ChatRoomViewModel: MediaMessageViewModelDelegate {
    func fetchVideoLocalUrl(fromUrlString urlString: String, onCompletion: @escaping (URL?) -> Void) {
        chatRoomMediaCache.getLocalUrl(fromOnlineUrlString: urlString, onCompletion: onCompletion)
    }

    func fetchImageData(fromUrlString urlString: String, onCompletion: @escaping (Data?) -> Void) {
        chatRoomMediaCache.getData(urlString: urlString, onCompletion: onCompletion)
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}

// MARK: MessageActionsViewModelDelegate
extension ChatRoomViewModel: MessageActionsViewModelDelegate {
    func delete(messageViewModel: MessageViewModel) {
        chatRoom.delete(message: messageViewModel.message)
    }

    func toggleLike(messageViewModel: MessageViewModel) {
        messageViewModel.message.toggleLike(of: user.id)
        // NOTE: This may cause a race condition if two likes are sent at around the same time.
        // However, it will be a no-fix for now because of the small scale of the application
        self.chatRoom.storeMessage(message: messageViewModel.message)
    }
}
