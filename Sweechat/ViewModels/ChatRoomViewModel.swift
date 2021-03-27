import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscribers: [AnyCancellable] = []

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
}

// MARK: Identifiable
extension ChatRoomViewModel: Identifiable {
}
