import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRoom: ChatRoom
    var user: User
    var subscriber: AnyCancellable?
    weak var delegate: ChatRoomDelegate?

    var text: String {
        "Chat room"
    }

    var messageCount: Int {
        chatRoom.messages.count
    }

    var textMessages: [MessageViewModel] {
        chatRoom.messages.map {
            MessageViewModel(message: $0, isCurrentUser: user.id == $0.sender.id)
        }
    }

    init(id: String, user: User) {
        self.chatRoom = ChatRoom(id: id)
        self.user = user
        subscriber = chatRoom.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        let message = Message(sender: user, content: text)
        self.chatRoom.storeMessage(message: message)
    }

    func didTapBackButton() {
        delegate?.navigateToModuleFromChatRoom()
    }
}
