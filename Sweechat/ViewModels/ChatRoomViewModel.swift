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

    init(id: String, name: String, user: User) {
        self.chatRoom = ChatRoom(id: id, name: name)
        self.user = user
        subscriber = chatRoom.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        let message = Message(senderId: user.id, content: text)
        self.chatRoom.storeMessage(message: message)
    }
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
