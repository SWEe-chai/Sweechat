import Combine
import Foundation
import os

class ChatRoom: ObservableObject, ChatRoomFacadeDelegate {
    var id: Identifier<ChatRoom>
    @Published var name: String
    @Published var profilePictureUrl: String?
    let ownerId: Identifier<User>
    var currentUser: User
    @Published var earlyLoadedMessages: [Identifier<Message>: Message] = [:]
    @Published var messages: [Identifier<Message>: Message] = [:]
    @Published var areAllMessagesLoaded: Bool = false
    private var chatRoomFacade: ChatRoomFacade?
    let currentUserPermission: ChatRoomPermissionBitmask
    var memberIdsToUsers: [Identifier<User>: User] = [:]
    var members: [User] {
        Array(memberIdsToUsers.values)
    }
    var isStarred: Bool
    private var groupCryptographyProvider: GroupCryptographyProvider

    static let allUsersId: Identifier<User> = "all"
    static let failedEncryptionMessageContent = "This chat room message could not be encrypted"
    static let failedDecryptionMessageContent = "This chat room message could not be decrypted"
    static let unavailableOwnerId = Identifier<User>("")
    static let unavailableChatRoomId = Identifier<ChatRoom>("")
    static let unavailableChatRoomName = "Unavailable Chat Room"

    // Pass owner ID here
    // This init is for the cloud service to create the chatroom and keep it in sync with the
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

    // Owner
    // This init is for frontend to create the ChatRoom, which we will then save on the cloud
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

    func setChatRoomConnection() {
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id, user: currentUser, delegate: self)
    }

    func storeMessage(message: Message) {
        let messageCopy = message.copy()
        if messageCopy.type != MessageType.keyExchange {
            messageCopy.content = encryptMessageContent(message: messageCopy)
        }

        self.chatRoomFacade?.save(messageCopy)
    }

    private func encryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.encrypt(plaintextData: message.content, groupId: id.val) {
            return content
        }

        os_log("Unable to encrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    func getUser(userId: Identifier<User>) -> User {
        memberIdsToUsers[userId] ?? User.createUnavailableInstance()
    }

    func loadMore() {
        chatRoomFacade?.loadNextBlock { messages in
            if messages.isEmpty {
                self.areAllMessagesLoaded = true
            }
            self.insertAll(messages: messages)
        }
    }

    func loadUntil(message: Message) {
        chatRoomFacade?.loadUntil(message.creationTime) {
            self.insertAll(messages: $0)
        }
    }

    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?) {
        self.chatRoomFacade?.uploadToStorage(data: data, fileName: fileName, onCompletion: onCompletion)
    }

    func subscribeToMessages(function: @escaping ([Identifier<Message>: Message]) -> Void) -> AnyCancellable {
        $messages.sink(receiveValue: function)
    }

    func subscribeToEarlyLoadedMessages(function: @escaping ([Identifier<Message>: Message]) -> Void) -> AnyCancellable {
        $earlyLoadedMessages.sink(receiveValue: function)
    }

    func subscribeToAreAllMessagesLoaded(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $areAllMessagesLoaded.sink(receiveValue: function)
    }

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    func subscribeToProfilePicture(function: @escaping (String?) -> Void) -> AnyCancellable {
        $profilePictureUrl.sink(receiveValue: function)
    }

    // MARK: ChatRoomFacadeDelegate
    func insert(message: Message) {
        if self.messages[message.id] != nil {
            return
        }
        processMessage(message)
        if let parentId = message.parentId,
           self.messages[parentId] == nil,
           self.earlyLoadedMessages[parentId] == nil {
            loadParentMessage(parentId: parentId)
        }
        self.earlyLoadedMessages.removeValue(forKey: message.id)
        self.messages[message.id] = message
    }

    func insertAll(messages: [Message]) {
        messages.forEach { insert(message: $0) }
    }

    private func loadParentMessage(parentId: Identifier<Message>) {
        chatRoomFacade?.loadMessage(withId: parentId.val) { message in
            guard let message = message else {
                os_log("Parent message does not exist \(parentId)")
                return
            }
            if self.messages[message.id] != nil
                || self.earlyLoadedMessages[message.id] != nil {
                return
            }
            self.processMessage(message)
            self.earlyLoadedMessages[message.id] = message
        }
    }

    private func processMessage(_ message: Message) {
        assert(message.type != MessageType.keyExchange)
        message.content = decryptMessageContent(message: message)
    }

    private func decryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.decrypt(ciphertextData: message.content, groupId: self.id.val) {
            return content
        }

        os_log("Unable to decrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    func remove(message: Message) {
        self.earlyLoadedMessages.removeValue(forKey: message.id)
        self.messages.removeValue(forKey: message.id)
    }

    func update(message: Message) {
        assert(earlyLoadedMessages[message.id] == nil
                || messages[message.id] == nil)
        processMessage(message)
        earlyLoadedMessages[message.id]?.update(message: message)
        messages[message.id]?.update(message: message)
    }

    func insert(member: User) {
        guard !self.members.contains(member) else {
            return
        }
        memberIdsToUsers[member.id] = member
    }

    func remove(member: User) {
        if !memberIdsToUsers.keys.contains(member.id) {
            return
        }
        memberIdsToUsers.removeValue(forKey: member.id)
    }

    func insertAll(members: [User]) {
        for member in members {
            memberIdsToUsers[member.id] = member
        }
    }

    func update(chatRoom: ChatRoom) {
        self.name = chatRoom.name
        self.profilePictureUrl = chatRoom.profilePictureUrl
    }

    func delete(message: Message) {
        chatRoomFacade?.delete(message)
    }

    func handleKeyExchangeMessages(keyExchangeMessages: [Message]) -> Bool {
        // No key exchange messages and user is owner
        if currentUser.id == ownerId {
            if keyExchangeMessages.isEmpty {
                os_log("Key bundles sent")
                chatRoomFacade?.loadPublicKeyBundlesFromStorage(of: members, onCompletion: performKeyExchange)
                storeMessage(
                    message: Message(
                        senderId: currentUser.id,
                        content: Data(),
                        type: .keyExchange,
                        receiverId: currentUser.id,
                        parentId: nil))
            }
            return true
        }

        // This is for non group creators
        guard let keyBundleMessage = keyExchangeMessages.first else {
            os_log("Key bundles not yet sent, number of key bundle messages: \(keyExchangeMessages.count)")
            return false
        }
        os_log("Received key bundles of size \(keyExchangeMessages.count)")
        // process single key bundle message
        processKeyExchangeMessage(keyBundleMessage)
        return true
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
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
