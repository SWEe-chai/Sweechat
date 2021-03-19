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
    private var messageListener: ListenerRegistration?

    var text: String {
        "Agnes Natasya Wijaya Chatting"
    }

    init(id: String) {
        chatRoom = ChatRoom(id: id)
    }

    func connectToFirebase(chatRoomId: String?) {
        reference = db.collection([DatabaseConstant.Collection.chatRooms,
                                   chatRoom.id,
                                   DatabaseConstant.Collection.messages].joined(separator: "/"))

        messageListener = reference?.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }

          snapshot.documentChanges.forEach { change in
            self.handleDocumentChange(change)
          }
        }

    }

    func handleSendMessage(_ text: String) {
        // TODO: Dont hardcode
        let message = Message(sender: AppConstant.user, content: text)
        self.save(message)
    }

    private func save(_ message: Message) {
        reference?.addDocument(data: MessageAdapter.convert(message: message)) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }

    private func insertNewMessage(_ message: Message) {
        guard !chatRoom.messages.contains(message) else {
            return
        }

        chatRoom.messages.append(message)
        chatRoom.messages.sort()
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = MessageAdapter.convert(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            insertNewMessage(message)

        default:
            break
        }
    }

}
