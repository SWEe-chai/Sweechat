import Combine
import SwiftUI
import FirebaseStorage
import os

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscribers: [AnyCancellable] = []

    @Published var text: String

    var permissions: ChatRoomType {
        ChatRoomType.convert(permission: chatRoom.permissions)
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    @Published var messages: [MessageViewModel]

    init(chatRoom: ChatRoom, user: User) {
        self.chatRoom = chatRoom
        self.user = user
        self.messages = chatRoom.messages.map {
            MessageViewModelFactory
                .makeViewModel(message: $0,
                               sender: chatRoom.getUser(userId: $0.id),
                               isSenderCurrentUser: user.id == $0.senderId)
        }
        self.text = chatRoom.name
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        let messagesSubscriber = chatRoom.subscribeToMessages { messages in
            self.messages = messages.map {
                MessageViewModelFactory
                    .makeViewModel(message: $0,
                                   sender: self.chatRoom.getUser(userId: $0.id),
                                   isSenderCurrentUser: self.user.id == $0.senderId)
            }
        }
        let chatRoomNameSubscriber = chatRoom.subscribeToName { newName in
            self.text = newName
        }
        subscribers.append(messagesSubscriber)
        subscribers.append(chatRoomNameSubscriber)
    }

    func handleSendMessage(_ text: String) {
        let message = Message(senderId: user.id, content: text.toData(), type: MessageType.text)
        self.chatRoom.storeMessage(message: message)
    }

    func handleSendImage(_ wrappedImage: Any?) {
        guard let image = wrappedImage as? UIImage else {
            os_log("wrappedImage is not UIImage")
            return
        }

        guard let data = image.jpegData(compressionQuality: 0.7) else {
            os_log("unable to get jpeg data for image")
            return
        }

        self.chatRoom.uploadToStorage(data: data, fileName: "\(UUID().uuidString).jpg") { url in
            let urlstring = url.absoluteString
            let message = Message(senderId: self.user.id, content: urlstring.toData(), type: MessageType.image)
            self.chatRoom.storeMessage(message: message)
        }
    }

    func handleSendVideo() {
        let message = Message(senderId: user.id, content: "Video".toData(), type: MessageType.video)
        self.chatRoom.storeMessage(message: message)
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
