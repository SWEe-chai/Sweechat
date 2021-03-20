import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscribers: [AnyCancellable]?

    var text: String {
        "Agnes Natasya Wijaya Chatting"
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var messages: [Message] {
        chatRoom.messages
    }

    init(id: String, user: User) {
        self.chatRoom = ChatRoom(id: id)
        self.user = user
        initialiseSubscribers()
    }

    func initialiseSubscribers() {
        subscribers = []
        let messageChangeSubscriber = chatRoom.subscribeToMesssagesChange { messages in
            print(messages.count)
            if messages == self.chatRoom.messages {
                return
            }
            self.chatRoom = ChatRoom(
                id: self.chatRoom.id,
                messages: messages
            )
        }
        subscribers?.append(messageChangeSubscriber)
    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        print("WHY")
        let message = Message(sender: user, content: text)
        self.chatRoom.storeMessage(message: message)
        print(self.chatRoom.messages.count)
    }
}
