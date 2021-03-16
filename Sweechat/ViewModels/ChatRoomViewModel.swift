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
        reference = db.collection(["chatRooms", chatRoom.id, "messages"].joined(separator: "/"))

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
        let user = User(id: "abc", firstName: "first", lastName: "last")
        let message = Message(user: user, content: text)
        print("sebelom")
        print(chatRoom.messages)
        save(message)
        print("sesuda")
        print(chatRoom.messages)
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
        print("kenapa ga kesini")
      guard !chatRoom.messages.contains(message) else {
        return
      }

      chatRoom.messages.append(message)
        print("kenapa ga kesini")
        print(chatRoom.messages)
      chatRoom.messages.sort()

        print("kenapa ga kesini3")
}

    private func handleDocumentChange(_ change: DocumentChange) {
        print("kesini gaaaa")
        print(chatRoom.messages)
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
