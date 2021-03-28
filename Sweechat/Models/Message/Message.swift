import Combine
import Foundation

class Message: ObservableObject {
    var id: String
    @Published var content: String
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

    func update(message: Message) {
        self.senderId = message.senderId
        self.creationTime = message.creationTime
        self.content = message.content
        self.type = message.type
        self.downloadUrl = message.downloadUrl
    }

    func subscribeToContent(function: @escaping (String) -> Void) -> AnyCancellable {
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
