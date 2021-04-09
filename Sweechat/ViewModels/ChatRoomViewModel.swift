import Combine
import SwiftUI
import FirebaseStorage
import os

class ChatRoomViewModel: ObservableObject {
    var chatRoom: ChatRoom
    var user: User
    private var chatRoomMediaCache: ChatRoomMediaCache
    private var subscribers: [AnyCancellable] = []

    @Published var text: String
    @Published var profilePictureUrl: String?

    var permissions: ChatRoomViewModelType {
        ChatRoomViewModelType.convert(permission: chatRoom.currentUserPermission)
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    @Published var messages: [MessageViewModel] = []

    init(chatRoom: ChatRoom, user: User) {
        self.chatRoom = chatRoom
        self.user = user
        self.text = chatRoom.name
        self.profilePictureUrl = chatRoom.profilePictureUrl
        self.chatRoomMediaCache = ChatRoomMediaCache(chatRoomId: chatRoom.id)
        self.messages = chatRoom.messages.compactMap {
            MessageViewModelFactory
                .makeViewModel(message: $0,
                               sender: chatRoom.getUser(userId: $0.id),
                               delegate: self,
                               isSenderCurrentUser: user.id == $0.senderId)
        }
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        let messagesSubscriber = chatRoom.subscribeToMessages { messages in
            // TODO: This resets all messages everytime a message gets changed,
            // might want to consider getting the new messages / deleted messages instead
            self.messages = messages.compactMap {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.senderId),
                                   delegate: self,
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
        }
        let chatRoomNameSubscriber = chatRoom.subscribeToName { newName in
            self.text = newName
        }
        subscribers.append(messagesSubscriber)
        subscribers.append(chatRoomNameSubscriber)
    }

    func handleSendMessage(_ text: String, withParentId parentId: String?) {
        let message = Message(senderId: user.id, content: text.toData(), type: MessageType.text,
                              receiverId: ChatRoom.allUsersId, parentId: parentId)
        self.chatRoom.storeMessage(message: message)
    }

    func handleSendImage(_ wrappedImage: Any?, withParentId parentId: String?) {
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

    func handleSendVideo(_ mediaURL: Any?, withParentId parentId: String?) {
        guard let url = mediaURL as? URL else {
            os_log("media url is not a url")
            print("media url: \(String(describing: mediaURL))")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            print(MemoryLayout.size(ofValue: data))
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
    func fetchVideoLocalUrl(fromUrl url: String, onCompletion: @escaping (String?) -> Void) {
        chatRoomMediaCache.getLocalUrl(fromOnlineUrl: url, onCompletion: onCompletion)
    }

    func fetchImageData(fromUrl url: String, onCompletion: @escaping (Data?) -> Void) {
        chatRoomMediaCache.getData(url: url, onCompletion: onCompletion)
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
