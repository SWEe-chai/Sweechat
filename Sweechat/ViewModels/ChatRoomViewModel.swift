import Firebase
import FirebaseFirestore

class ChatRoomViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    @Published var chatRoom: ChatRoom
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

    private func insertNewMessage(_ message: Message) {
      guard !chatRoom.messages.contains(message) else {
        return
      }

      chatRoom.messages.append(message)
      chatRoom.messages.sort()
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard var message = MessageAdapter.convert(document: change.document) else {
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
