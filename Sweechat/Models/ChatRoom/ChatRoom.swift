import Combine
import Foundation
import os

/**
 Represents a chat room in the application.
 */
class ChatRoom: ObservableObject, ChatRoomFacadeDelegate {
    static let allUsersId: Identifier<User> = "all"
    static let failedEncryptionMessageContent = "This chat room message could not be encrypted"
    static let failedDecryptionMessageContent = "This chat room message could not be decrypted"
    static let unavailableOwnerId = Identifier<User>("")
    static let unavailableChatRoomId = Identifier<ChatRoom>("")
    static let unavailableChatRoomName = "Unavailable Chat Room"

    let id: Identifier<ChatRoom>
    let ownerId: Identifier<User>
    let currentUser: User
    let currentUserPermission: ChatRoomPermissionBitmask
    var memberIdsToUsers: [Identifier<User>: User] = [:]
    var isStarred: Bool

    @Published var name: String
    @Published var profilePictureUrl: String?
    @Published var earlyLoadedMessages: [Identifier<Message>: Message] = [:]
    @Published var messages: [Identifier<Message>: Message] = [:]
    @Published var areAllMessagesLoaded: Bool = false

    private var groupCryptographyProvider: GroupCryptographyProvider
    private var chatRoomFacade: ChatRoomFacade?

    var members: [User] {
        Array(memberIdsToUsers.values)
    }

    /// Creates an instance of an unavailable `ChatRoom`.
    /// This method should be called when there is an error retrieving chatroom information from the server.
    /// - Returns: An instance of an unavailable `ChatRoom`.
    static func createUnavailableInstance() -> GroupChatRoom {
        GroupChatRoom(
            id: unavailableChatRoomId,
            name: unavailableChatRoomName,
            ownerId: unavailableOwnerId,
            currentUser: User.createUnavailableInstance(),
            currentUserPermission: ChatRoomPermissionBitmask(),
            isStarred: false
        )
    }

    // MARK: Initialization

    /// Constructs a `ChatRoom` for use in facade translation with the cloud service provider.
    init(id: Identifier<ChatRoom>,
         name: String,
         ownerId: Identifier<User>,
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         isStarred: Bool,
         profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.currentUser = currentUser
        self.profilePictureUrl = profilePictureUrl
        self.currentUserPermission = currentUserPermission
        self.isStarred = isStarred
        self.groupCryptographyProvider = SignalProtocol(userId: currentUser.id.val)
    }

    /// Constructs a `ChatRoom` to display on the screen.
    init(name: String,
         members: [User],
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         isStarred: Bool,
         givenChatRoomId: Identifier<ChatRoom> = Identifier(val: UUID().uuidString),
         profilePictureUrl: String? = nil) {
        self.id = givenChatRoomId
        self.name = name
        self.ownerId = currentUser.id
        self.currentUser = currentUser
        self.profilePictureUrl = profilePictureUrl
        self.currentUserPermission = currentUserPermission
        self.isStarred = isStarred
        self.groupCryptographyProvider = SignalProtocol(userId: currentUser.id.val)
        insertAll(members: members)
    }

    // MARK: Facade Connection

    /// Sets up a connection to the server to listen to updates to this `ChatRoom`.
    func setChatRoomConnection() {
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id, user: currentUser, delegate: self)
    }

    /// Stores the specified `Message` on the server.
    /// - Parameters:
    ///   - message: The specified `Message`.
    func storeMessage(message: Message) {
        let messageCopy = message.copy()

        if messageCopy.type != MessageType.keyExchange {
            messageCopy.content = encryptMessageContent(message: messageCopy)
        }

        self.chatRoomFacade?.save(messageCopy)
    }

    /// Uploads the specified file data to the server and executes the specified function on completion.
    /// - Parameters:
    ///   - data: The specified file data.
    ///   - fileName: The specified file name.
    ///   - onCompletion: The function to execute on completion.
    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?) {
        self.chatRoomFacade?.uploadToStorage(data: data, fileName: fileName, onCompletion: onCompletion)
    }

    // MARK: Pagination

    /// Loads the next block of messages.
    func loadMore() {
        chatRoomFacade?.loadNextBlockOfMessages { messages in
            if messages.isEmpty {
                self.areAllMessagesLoaded = true
            }
            self.insertAll(messages: messages)
        }
    }

    /// Loads all messages until the specified message in chronological ordering
    /// - Parameters:
    ///   - message: The specified `Message`.
    func loadUntil(message: Message) {
        chatRoomFacade?.loadMessagesUntil(message.creationTime) {
            self.insertAll(messages: $0)
        }
    }

    // MARK: Subscriptions

    /// Subscribes to the this `ChatRoom`'s messages by executing the specified function on change to the messages.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the messages
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToMessages(function: @escaping ([Identifier<Message>: Message]) -> Void) -> AnyCancellable {
        $messages.sink(receiveValue: function)
    }

    /// Subscribes to the this `ChatRoom`'s early loaded messages by executing the specified function
    /// on change to the early loaded messages.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the early loaded messages.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToEarlyLoadedMessages(function: @escaping ([Identifier<Message>: Message]) -> Void)
            -> AnyCancellable {
        $earlyLoadedMessages.sink(receiveValue: function)
    }

    /// Subscribes to the this `ChatRoom`'s message load by executing the specified function once all messages are loaded.
    /// - Parameters:
    ///   - function: The specified function to execute once all messages are loaded.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToAreAllMessagesLoaded(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $areAllMessagesLoaded.sink(receiveValue: function)
    }

    /// Subscribes to the this `ChatRoom`'s name load by executing the specified function on change to the name.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the name.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    /// Subscribes to the this `ChatRoom`'s name load by executing the specified function on change to the profile picture.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the profile picture.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToProfilePicture(function: @escaping (String?) -> Void) -> AnyCancellable {
        $profilePictureUrl.sink(receiveValue: function)
    }

    // MARK: ChatRoomFacadeDelegate

    /// Inserts the specified `Message` into this `ChatRoom`.
    /// - Parameters:
    ///  - message: The specified `Message`.
    func insert(message: Message) {
        if self.messages[message.id] != nil {
            return
        }

        decryptMessageIfNecessary(message)

        if let parentId = message.parentId,
           self.messages[parentId] == nil,
           self.earlyLoadedMessages[parentId] == nil {
            loadParentMessage(parentId: parentId)
        }

        self.earlyLoadedMessages.removeValue(forKey: message.id)
        self.messages[message.id] = message
    }

    /// Inserts the specified `Message`s into this `ChatRoom`.
    /// - Parameters:
    ///  - messages: The specified `Message`s.
    func insertAll(messages: [Message]) {
        messages.forEach { insert(message: $0) }
    }

    /// Handles the specified key exchange messages based on whether the current `User` is this `ChatRoom`s creator.
    /// - Parameters:
    ///  - keyExchangeMessages: The specified key exchange messages.
    func handleKeyExchangeMessages(keyExchangeMessages: [Message]) -> Bool {
        // No key exchange messages and user is owner
        if currentUser.id == ownerId && keyExchangeMessages.isEmpty {
            os_log("Key bundles sent")
            sendKeyExchangeBundles()
            return true
        }

        // Non group creators
        guard let keyBundleMessage = keyExchangeMessages.first else {
            os_log("Key bundles not yet sent, number of key bundle messages: \(keyExchangeMessages.count)")
            return false
        }

        // Process single key bundle message
        os_log("Received key bundles of size \(keyExchangeMessages.count)")
        processKeyExchangeMessage(keyBundleMessage)
        return true
    }

    /// Updates the specified `Message` in this `ChatRoom`.
    /// - Parameters:
    ///  - messages: The specified `Message`.
    func update(message: Message) {
        assert(earlyLoadedMessages[message.id] == nil || messages[message.id] == nil)
        decryptMessageIfNecessary(message)
        earlyLoadedMessages[message.id]?.update(message: message)
        messages[message.id]?.update(message: message)
    }

    /// Gets the `User` with the specified ID.
    /// - Parameters:
    ///  - userId: The specified ID.
    /// - Returns: The `User` with the specified ID if exists in this `ChatRoom`, or an unavailable `User` otherwise.
    func getUser(userId: Identifier<User>) -> User {
        memberIdsToUsers[userId] ?? User.createUnavailableInstance()
    }

    /// Removes the specified `Message` from this `ChatRoom`.
    /// - Parameters:
    ///  - messages: The specified `Message`.
    func remove(message: Message) {
        self.earlyLoadedMessages.removeValue(forKey: message.id)
        self.messages.removeValue(forKey: message.id)
    }

    /// Inserts the specified `User` into this `ChatRoom`.
    /// - Parameters:
    ///  - member: The specified `User`.
    func insert(member: User) {
        if !self.members.contains(member) {
            memberIdsToUsers[member.id] = member
        }
    }

    /// Removes the specified `User` from this `ChatRoom`.
    /// - Parameters:
    ///  - member: The specified `User`.
    func remove(member: User) {
        if memberIdsToUsers.keys.contains(member.id) {
            memberIdsToUsers.removeValue(forKey: member.id)
        }
    }

    /// Inserts the specified `User`s into this `ChatRoom`.
    /// - Parameters:
    ///  - members: The specified `User`s.
    func insertAll(members: [User]) {
        for member in members {
            memberIdsToUsers[member.id] = member
        }
    }

    /// Updates this `ChatRoom` with information from the specified `ChatRoom`.
    /// - Parameters:
    ///   - message: The specified `ChatRoom`.
    func update(chatRoom: ChatRoom) {
        self.name = chatRoom.name
        self.profilePictureUrl = chatRoom.profilePictureUrl
    }

    /// Deletes the specified `Message` from this `ChatRoom`.
    /// - Parameters:
    ///  - message: The specified `Message`.
    func delete(message: Message) {
        chatRoomFacade?.delete(message)
    }

    // MARK: Private Helper Methods

    private func encryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.encrypt(plaintextData: message.content, groupId: id.val) {
            return content
        }

        os_log("Unable to encrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    private func decryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.decrypt(ciphertextData: message.content, groupId: self.id.val) {
            return content
        }

        os_log("Unable to decrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    private func decryptMessageIfNecessary(_ message: Message) {
        if message.type != MessageType.keyExchange {
            message.content = decryptMessageContent(message: message)
        }
    }

    private func sendKeyExchangeBundles() {
        chatRoomFacade?.loadPublicKeyBundlesFromStorage(of: members, onCompletion: performKeyExchange)
        storeMessage(
            message: Message(
                senderId: currentUser.id,
                content: Data(),
                type: .keyExchange,
                receiverId: currentUser.id,
                parentId: nil))
    }

    private func loadParentMessage(parentId: Identifier<Message>) {
        chatRoomFacade?.loadMessage(withId: parentId.val) { message in
            guard let message = message else {
                os_log("Parent message does not exist \(parentId)")
                return
            }

            if self.messages[message.id] == nil && self.earlyLoadedMessages[message.id] == nil {
                self.decryptMessageIfNecessary(message)
                self.earlyLoadedMessages[message.id] = message
            }
        }
    }

    private func performKeyExchange(publicKeyBundles: [String: Data]) {
        for member in members where member.id != currentUser.id {
            guard let bundleData = publicKeyBundles[member.id.val] else {
                os_log("Unable to get public key bundle from chat room member")
                return
            }

            guard let keyExchangeBundleData = try? groupCryptographyProvider
                    .generateKeyExchangeDataFrom(serverKeyBundleData: bundleData, groupId: self.id.val) else {
                os_log("Unable to generate key exchange bundle")
                return
            }

            storeMessage(message: Message(senderId: currentUser.id,
                                          content: keyExchangeBundleData,
                                          type: MessageType.keyExchange,
                                          receiverId: member.id,
                                          parentId: nil))
        }
    }

    private func processKeyExchangeMessage(_ message: Message) {
        do {
            try groupCryptographyProvider.process(keyExchangeBundleData: message.content, groupId: self.id.val)
        } catch {
            os_log("Unable to process key exchange bundle from group creator")
        }
    }
}

extension ChatRoom: Equatable {
    /// Whether two `ChatRoom`s are equal.
    /// - Parameters:
    ///   - lhs: The first `ChatRoom`.
    ///   - rhs: The second `ChatRoom`.
    /// - Returns: `true` if the two `ChatRoom`s are equal.
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
