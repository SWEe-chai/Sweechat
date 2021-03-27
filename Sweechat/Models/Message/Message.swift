import Combine
import Foundation

class Message: ObservableObject {
    var id: String
    @Published var content: Data
    var creationTime: Date
    var senderId: String
    var type: MessageType

    init(senderId: String, content: Data) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = UUID().uuidString
        self.type = MessageType.text
    }

    init(id: String, senderId: String, creationTime: Date, content: Data) {
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

// TODO: Remove this extension later
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
