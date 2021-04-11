import Combine
import Foundation

class Message: ObservableObject {
    let parentId: String?
    var id: Identifier<Message>
    @Published var content: Data
    var creationTime: Date
    var senderId: String
    var type: MessageType
    var receiverId: String

    // This message init is for creating new messages in the front end
    init(senderId: String,
         content: Data,
         type: MessageType,
         receiverId: String,
         parentId: String?,
         id: Identifier<Message> = Identifier(val: UUID().uuidString)) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = id
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
    }

    // This message init is for facade to translate
    init(id: Identifier<Message>,
         senderId: String,
         creationTime: Date,
         content: Data,
         type: MessageType,
         receiverId: String,
         parentId: String?) {
        self.id = id
        self.senderId = senderId
        self.creationTime = creationTime
        self.content = content
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
    }

    func update(message: Message) {
        if self.content != message.content {
            self.content = message.content
        }
    }

    func subscribeToContent(function: @escaping (Data) -> Void) -> AnyCancellable {
        $content.sink(receiveValue: function)
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.creationTime < rhs.creationTime
    }
}

extension String {
    func toData() -> Data {
        Data(self.utf8)
    }
}

extension Data {
    func toString() -> String {
        String(decoding: self, as: UTF8.self)
    }
}
