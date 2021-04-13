import Combine
import SwiftUI
import FirebaseStorage
import os

class ChatRoomViewModel: ObservableObject {
    var chatRoom: ChatRoom
    var user: User
    private var chatRoomMediaCache: ChatRoomMediaCache
    private var subscribers: [AnyCancellable] = []

    @Published var editedMessageViewModel: MessageViewModel?
    @Published var text: String
    @Published var profilePictureUrl: String?
    @Published var areAllMessagesLoaded: Bool = false

    var permissions: ChatRoomViewModelType {
        ChatRoomViewModelType.convert(permission: chatRoom.currentUserPermission)
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var editedMessageContent: String {
        editedMessageViewModel?.previewContent() ?? ""
    }
    @Published var messages: [MessageViewModel] = []
    @Published var earlyLoadedMessages: [MessageViewModel] = []

    var messageIdToMessages: [Identifier<Message>: Message] = [:]

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
            // TODO: This resets all messages everytime a message gets changed,
            // might want to consider getting the new messages / deleted messages instead
            self.messages = messages.compactMap {
                let viewModel = MessageViewModelFactory
                                    .makeViewModel(
                                        message: $0,
                                        sender: self.chatRoom.getUser(userId: $0.senderId),
                                        delegate: self,
                                        currentUserId: self.user.id,
                                        messageIdToMessages: [:])
                viewModel?.delegate = self
                return viewModel
            }
        }
        let earlyMessagesSubscriber = chatRoom.subscribeToEarlyLoadedMessages { messages in
            self.earlyLoadedMessages = messages.compactMap {
                MessageViewModelFactory
                    .makeViewModel(
                        message: $0,
                        sender: self.chatRoom.getUser(userId: $0.senderId),
                        delegate: self,
                        currentUserId: self.user.id,
                        messageIdToMessages: [:])
            }
        }
        let chatRoomNameSubscriber = chatRoom.subscribeToName { newName in
            self.text = newName
        }
        let allMessagesLoadedSubscriber = chatRoom.subscribeToAreAllMessagesLoaded { self.areAllMessagesLoaded = $0
        }
        subscribers.append(messagesSubscriber)
        subscribers.append(chatRoomNameSubscriber)
        subscribers.append(earlyMessagesSubscriber)
        subscribers.append(allMessagesLoadedSubscriber)
    }

    func loadMore() {
        chatRoom.loadMore(10)
    }

    func loadUntil(messageViewModel: MessageViewModel) {
        chatRoom.loadUntil(message: messageViewModel.message)
    }

    func getMessageViewModel(withId id: String?) -> MessageViewModel? {
        guard let messageId = id else {
            return nil
        }
        var message = messages.first { $0.id == messageId }
        message = earlyLoadedMessages.first { $0.id == messageId }
        return message
    }

    func handleSendMessage(_ text: String, withParentId parentId: Identifier<Message>?) {
        if let editedMessageViewModel = editedMessageViewModel {
            editedMessageViewModel.message.content = text.toData()
            self.chatRoom.storeMessage(message: editedMessageViewModel.message)
            self.editedMessageViewModel = nil
        } else {
            let message = Message(senderId: user.id, content: text.toData(), type: MessageType.text,
                                  receiverId: ChatRoom.allUsersId, parentId: parentId)
            self.chatRoom.storeMessage(message: message)
        }
    }

    func handleSendImage(_ wrappedImage: Any?, withParentId parentId: Identifier<Message>?) {
        guard let image = wrappedImage as? UIImage else {
            os_log("wrappedImage is not UIImage")
            return
        }

        guard let data = image.jpegData(compressionQuality: 0.05) else {
            os_log("unable to get jpeg data for image")
            return
        }

        self.chatRoom.uploadToStorage(data: data, fileName: "\(UUID().uuidString).jpg") { url in
            let urlstring = url.absoluteString
            let message = Message(senderId: self.user.id, content: urlstring.toData(), type: MessageType.image,
                                  receiverId: ChatRoom.allUsersId, parentId: parentId)
            self.chatRoom.storeMessage(message: message)
        }
    }

    func handleSendVideo(_ mediaURL: Any?, withParentId parentId: Identifier<Message>?) {
        guard let url = mediaURL as? URL else {
            os_log("media url is not a url")
            print("media url: \(String(describing: mediaURL))")
            return
        }

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
    func edit(messageViewModel: MessageViewModel) {
        editedMessageViewModel = messageViewModel
    }

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
