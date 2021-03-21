import Foundation

struct Message {
    var id: String
    var content: String
    var creationTime: Date
    var sender: User
    var type: MessageType
    var downloadUrl: URL?

    init(sender: User, content: String) {
        self.sender = sender
        self.content = content
        self.creationTime = Date()
        self.id = UUID().uuidString
        self.type = MessageType.text
    }

    init(id: String, sender: User, creationTime: Date, content: String) {
        self.id = id
        self.sender = sender
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
