import Combine
import Foundation

typealias UserId = String // TODO: Make use of type-safe identifiers

class Message: ObservableObject {
    let parentId: String?
    var id: String
    @Published var content: Data
    var creationTime: Date
    var senderId: String
    var type: MessageType
    var receiverId: String
    var likers: Set<UserId>

    // This message init is for creating new messages in the front end
    init(senderId: String, content: Data, type: MessageType,
         receiverId: String, parentId: String?, id: String = UUID().uuidString) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = id
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
        self.likers = []
    }

    // This message init is for facade to translate
    init(id: String, senderId: String, creationTime: Date,
         content: Data, type: MessageType, receiverId: String, parentId: String?) {
        self.id = id
        self.senderId = senderId
        self.creationTime = creationTime
        self.content = content
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
        self.likers = []
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
