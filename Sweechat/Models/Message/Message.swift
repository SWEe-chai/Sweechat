import Foundation

class Message {
    var id: String
    var content: String
    var creationTime: Date
    var senderId: String
    var type: MessageType
    var downloadUrl: URL?

    init(senderId: String, content: String) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = UUID().uuidString
        self.type = MessageType.text
    }

    init(id: String, senderId: String, creationTime: Date, content: String) {
        self.id = id
        self.senderId = senderId
        self.creationTime = creationTime
        self.content = content
        self.type = MessageType.text
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
