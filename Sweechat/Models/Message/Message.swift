import Combine
import Foundation
import os

class Message: ObservableObject {
    let id: Identifier<Message>
    let parentId: Identifier<Message>?
    let senderId: Identifier<User>
    let receiverId: Identifier<User>
    let type: MessageType
    let creationTime: Date

    @Published var content: Data
    @Published var likers: Set<Identifier<User>>

    // MARK: Initialization

    // For creating new messages in the frontend
    init(senderId: Identifier<User>,
         content: Data,
         type: MessageType,
         receiverId: Identifier<User>,
         parentId: Identifier<Message>?,
         id: Identifier<Message> = Identifier(val: UUID().uuidString)) {
        self.senderId = senderId
        self.content = content
        self.creationTime = Date()
        self.id = id
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
        self.likers = []
    }

    // For facade translation
    init(id: Identifier<Message>,
         senderId: Identifier<User>,
         creationTime: Date,
         content: Data,
         type: MessageType,
         receiverId: Identifier<User>,
         parentId: Identifier<Message>?,
         likers: Set<Identifier<User>>) {
        self.id = id
        self.senderId = senderId
        self.creationTime = creationTime
        self.content = content
        self.type = type
        self.receiverId = receiverId
        self.parentId = parentId
        self.likers = likers
    }

    // MARK: Copying

    func copy() -> Message {
        Message(id: id, senderId: senderId, creationTime: creationTime,
                content: content, type: type, receiverId: receiverId,
                parentId: parentId, likers: likers)
    }

    // MARK: Mutation

    func update(message: Message) {
        self.content = message.content
        self.likers = message.likers
    }

    func toggleLike(of userId: Identifier<User>) {
        if likers.contains(userId) {
            os_log("INFO: user \(userId) is in message \(self.id)'s likers")
            likers.remove(userId)
        } else {
            os_log("INFO: user \(userId) is NOT in message \(self.id)'s likers")
            likers.insert(userId)
        }
    }

    // MARK: Subscriptions

    func subscribeToContent(function: @escaping (Data) -> Void) -> AnyCancellable {
        $content.sink(receiveValue: function)
    }

    func subscribeToLikers(function: @escaping (Set<Identifier<User>>) -> Void) -> AnyCancellable {
        $likers.sink(receiveValue: function)
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

extension Message: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
