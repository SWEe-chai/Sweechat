import Combine
import Foundation

class Message: ObservableObject {
    let parentId: String?
    var id: String
    @Published var content: Data
    var creationTime: Date
    var senderId: String
    var type: MessageType
    var receiverId: String

    init(senderId: String, content: Data, type: MessageType, receiverId: String, parentId: String?) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = UUID().uuidString
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
    }

    init(id: String, senderId: String, creationTime: Date,
         content: Data, type: MessageType, receiverId: String, parentId: String?) {
        self.id = id
        self.senderId = senderId
        self.creationTime = creationTime
        self.content = content
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
    }

    func update(message: Message) {
        self.senderId = message.senderId
        self.creationTime = message.creationTime
        self.content = message.content
        self.type = message.type
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
