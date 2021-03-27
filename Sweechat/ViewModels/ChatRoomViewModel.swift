import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscriber: AnyCancellable?

    var text: String {
        chatRoom.name
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var textMessages: [MessageViewModel] {
        chatRoom.messages.map {
            MessageViewModel(message: $0, sender: chatRoom.getUser(userId: $0.id), isSenderCurrentUser: user.id == $0.senderId)
        }
    }

    init(chatRoom: ChatRoom, user: User) {
        self.chatRoom = chatRoom
        self.user = user
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        subscriber = chatRoom.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func removeSubscriber() {
        subscriber = nil
    }

    func handleSendMessage(_ text: String) {
        let message = Message(senderId: user.id, content: text)
        self.chatRoom.storeMessage(message: message)
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
