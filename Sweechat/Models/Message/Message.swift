import Combine
import Foundation
import os

/**
 Represents a message with varying content type (e.g. text, image, video, etc.).
 */
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

    /// Constructs a `Message` to display on the screen.
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

    /// Constructs a `Message` for use in facade translation with the cloud service provider.
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

    /// Creates a copy of this message.
    /// - Returns: A copy of this message.
    func copy() -> Message {
        Message(id: id, senderId: senderId, creationTime: creationTime,
                content: content, type: type, receiverId: receiverId,
                parentId: parentId, likers: likers)
    }

    // MARK: Mutation

    /// Updates this `Message` with information from the specified `Message`.
    /// - Parameters:
    ///   - message: The specified `Message`.
    func update(message: Message) {
        self.content = message.content
        self.likers = message.likers
    }

    /// Toggles the like status from the specified user ID to this message.
    /// - Parameters:
    ///   - userId: The specified user ID.
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

    /// Subscribes to the content in this message by executing the specified function on change to the content.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the content.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToContent(function: @escaping (Data) -> Void) -> AnyCancellable {
        $content.sink(receiveValue: function)
    }

    /// Subscribes to the likers in this message by executing the specified function on change to the content.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the likers.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToLikers(function: @escaping (Set<Identifier<User>>) -> Void) -> AnyCancellable {
        $likers.sink(receiveValue: function)
    }
}

extension Message: Comparable {
    /// Whether two `Message`s are equal.
    /// - Parameters:
    ///   - lhs: The first `Message`.
    ///   - rhs: The second `Message`.
    /// - Returns: `true` if the two `Message`s are equal.
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    /// Whether the first `Message` is less than the second.
    /// - Parameters:
    ///   - lhs: The first `Message`.
    ///   - rhs: The second `Message`.
    /// - Returns: `true` if the first `Message` is less than the second.
    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.creationTime < rhs.creationTime
    }
}

extension Message: Hashable {
    /// Hashes this `Message` into the specified `Hasher`.
    /// - Parameters:
    ///   - hasher: The specified `Hasher`.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension String {
    /// The `Data` representation of this `String`.
    /// - Returns: The `Data` representation of this `String`.
    func toData() -> Data {
        Data(self.utf8)
    }
}

extension Data {
    /// The `String` representation of this `Data`.
    /// - Returns: The `String` representation of this `Data`.
    func toString() -> String {
        String(decoding: self, as: UTF8.self)
    }
}
