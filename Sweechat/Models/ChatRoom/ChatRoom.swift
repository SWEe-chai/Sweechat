import Combine
import Foundation
import os

class ChatRoom: ObservableObject, ChatRoomFacadeDelegate {
    var id: String
    @Published var name: String
    var profilePictureUrl: String?
    let ownerId: String
    var currentUser: User
    @Published var messages: [Message]
    private var chatRoomFacade: ChatRoomFacade?
    let currentUserPermission: ChatRoomPermissionBitmask
    var memberIdsToUsers: [String: User] = [:]
    var members: [User] {
        Array(memberIdsToUsers.values)
    }
    private var groupCryptographyProvider: GroupCryptographyProvider

    static let allUsersId: String = "all"
    static let failedEncryptionMessageContent = "This chat room message could not be encrypted"
    static let failedDecryptionMessageContent = "This chat room message could not be decrypted"

    // Pass owner ID here
    // This init is for the cloud service to create the chatroom and keep it in sync with the
    init(id: String,
         name: String,
         ownerId: String,
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.currentUser = currentUser
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.currentUserPermission = currentUserPermission
        self.groupCryptographyProvider = SignalProtocol(userId: currentUser.id)
    }

    // Owner
    // This init is for frontend to create the ChatRoom, which we will then save on the cloud
    init(name: String,
         members: [User],
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         givenChatRoomId: String = UUID().uuidString,
         profilePictureUrl: String? = nil) {
        self.id = givenChatRoomId
        self.name = name
        self.ownerId = currentUser.id
        self.currentUser = currentUser
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.currentUserPermission = currentUserPermission
        self.groupCryptographyProvider = SignalProtocol(userId: currentUser.id)
        insertAll(members: members)
    }

    func setChatRoomConnection() {
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id, user: currentUser)
        chatRoomFacade?.delegate = self
    }

    func storeMessage(message: Message) {
        if message.type != MessageType.keyExchange {
            message.content = encryptMessageContent(message: message)
        }

        self.chatRoomFacade?.save(message)
    }

    private func encryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.encrypt(plaintextData: message.content, groupId: id) {
            return content
        }

        os_log("Unable to encrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    func getUser(userId: String) -> User {
        memberIdsToUsers[userId] ?? User.createUnavailableUser()
    }

    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?) {
        self.chatRoomFacade?.uploadToStorage(data: data, fileName: fileName, onCompletion: onCompletion)
    }

    func subscribeToMessages(function: @escaping ([Message]) -> Void) -> AnyCancellable {
        $messages.sink(receiveValue: function)
    }

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    // MARK: ChatRoomFacadeDelegate
    func insert(message: Message) {
        if self.messages.contains(message) {
            return
        }

        processMessage(message)
        self.messages.append(message)
        self.messages.sort(by: { $0.creationTime < $1.creationTime })
    }

    func insertAll(messages: [Message]) {
        let newMessages = messages.sorted(by: { $0.creationTime < $1.creationTime })

        for message in newMessages {
            processMessage(message)
        }

        self.messages = newMessages
    }

    private func processMessage(_ message: Message) {
        assert(message.type != MessageType.keyExchange)
        message.content = decryptMessageContent(message: message)
    }

    private func decryptMessageContent(message: Message) -> Data {
        if let content = try? groupCryptographyProvider.decrypt(ciphertextData: message.content, groupId: self.id) {
            return content
        }

        os_log("Unable to decrypt chat room message")
        return ChatRoom.failedEncryptionMessageContent.toData()
    }

    func remove(message: Message) {
        if let index = messages.firstIndex(of: message) {
            self.messages.remove(at: index)
        }
    }

    func update(message: Message) {
        if let index = messages.firstIndex(of: message) {
            processMessage(message)
            self.messages[index].update(message: message)
        }
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

    func provideKeyExchangeMesssages(messages: [Message]) -> Bool {
        // No key exchange messages and user is owner
        if currentUser.id == ownerId {
            if messages.isEmpty {
                os_log("Key bundles sent")
                chatRoomFacade?.loadPublicKeyBundlesFromStorage(of: members, onCompletion: performKeyExchange)
                storeMessage(
                    message: Message(
                        senderId: currentUser.id,
                        content: Data(),
                        type: .keyExchange,
                        receiverId: currentUser.id, parentId: nil))
            }
            return true
        }

        // This is for non group creators
        guard let keyBundleMessage = messages.first else {
            os_log("Key bundles not yet sent, number of key bundle messages: \(messages.count)")
            return false
        }
        os_log("Received key bundles of size \(messages.count)")
        // process single key bundle message
        processKeyExchangeMessage(keyBundleMessage)
        return true
    }

    private func performKeyExchange(publicKeyBundles: [String: Data]) {
        for member in members where member.id != currentUser.id {
            guard let bundleData = publicKeyBundles[member.id] else {
                os_log("Unable to get public key bundle from chat room member")
                return
            }

            guard let keyExchangeBundleData = try? groupCryptographyProvider
                    .generateKeyExchangeDataFrom(serverKeyBundleData: bundleData, groupId: self.id) else {
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
            try groupCryptographyProvider.process(keyExchangeBundleData: message.content, groupId: self.id)
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
