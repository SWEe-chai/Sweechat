import Combine
import SwiftUI
import FirebaseStorage

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscribers: [AnyCancellable] = []
    // TODO: Move this to Facade level instead of here
    private var storage = Storage.storage().reference()

    @Published var text: String

    var messageCount: Int {
        chatRoom.messages.count
    }

    @Published var textMessages: [MessageViewModel]

    init(chatRoom: ChatRoom, user: User) {
        self.chatRoom = chatRoom
        self.user = user
        self.textMessages = chatRoom.messages.map {
            MessageViewModel(
                message: $0,
                sender: chatRoom.getUser(userId: $0.id),
                isSenderCurrentUser: user.id == $0.senderId)
        }
        self.text = chatRoom.name
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        let messagesSubscriber = chatRoom.subscribeToMessages { messages in
            self.textMessages = messages.map { MessageViewModel(
                message: $0,
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

    func handleSendImage(_ image: UIImage?) {
        guard let unwrapped = image else {
            print("empty image paased in")
            return
        }
        guard let data = unwrapped.jpegData(compressionQuality: 0.7) else {
            print("unable to get png data")
            return
        }
        uploadToStorage(data: data, fileName: "\(UUID().uuidString).jpg") { url in
            let urlstring = url.absoluteString
            let message = Message(senderId: self.user.id, content: urlstring.toData(), type: MessageType.image)
            print("the download url is: \(urlstring)")
            self.chatRoom.storeMessage(message: message)
        }
    }

    func uploadToStorage(data: Data, fileName: String, completion: ((URL) -> Void)? = nil) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { _, err in
            guard err == nil else {
                // failed
                print("failed to uplodad data to firebase")
                return
            }

            self.storage.child("images/\(fileName)").downloadURL { url, _ in
                guard let url = url else {
                    print("failed to get download url")
                    return
                }

                completion?(url)
            }
        }
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
