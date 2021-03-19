import Firebase
import FirebaseFirestore

class ChatRoomViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    @Published var chatRoom: ChatRoom {
        didSet {
            objectWillChange.send()
        }
    }
    var user: User
    private var messageListener: ListenerRegistration?

    var text: String {
        "Agnes Natasya Wijaya Chatting"
    }

    init(id: String, user: User) {
        chatRoom = ChatRoom(id: id)
        self.user = user
    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        let message = Message(sender: user, content: text)
        self.chatRoom.insert(message: message)
    }
}
