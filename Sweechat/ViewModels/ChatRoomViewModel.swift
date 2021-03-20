import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscriber: AnyCancellable?
    weak var delegate: ChatRoomDelegate?

    var text: String {
        "Agnes Natasya Wijaya Chatting"
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var textMessages: [String] {
        chatRoom.messages.map { "\($0.content) from \($0.sender.name)" }
    }

    init(id: String, user: User) {
        self.chatRoom = ChatRoom(id: id)
        self.user = user
        subscriber = chatRoom.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func initialiseSubscribers() {
//        let messageChangeSubscriber = chatRoom.subscribeToMesssagesChange { messages in
//            print(messages.count)
//            if messages == self.chatRoom.messages {
//                return
//            }
//        }
//        subscriber = chatRoom
    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        let message = Message(sender: user, content: text)
        self.chatRoom.storeMessage(message: message)
        print(self.chatRoom.messages.count)
    }

    func didTapBackButton() {
        delegate?.navigateToModuleFromChatRoom()
    }
}
