//
//  ChatRoom.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//
import Combine
import Foundation

class ChatRoom: ObservableObject, ChatRoomFacadeDelegate {
    var id: String
    @Published var name: String
    var profilePictureUrl: String?
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

    init(id: String,
         name: String,
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.currentUser = currentUser
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.currentUserPermission = currentUserPermission
        self.groupCryptographyProvider = SignalProtocol(userId: currentUser.id)
    }

    init(name: String,
         members: [User],
         currentUser: User,
         currentUserPermission: ChatRoomPermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
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
        self.chatRoomFacade?.save(message)
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
        guard !self.messages.contains(message) else {
            return
        }
        self.messages.append(message)
        self.messages = self.messages.filter({ $0.receiverId == ChatRoom.allUsersId || $0.receiverId == self.id })
        self.messages.sort(by: { $0.creationTime < $1.creationTime })

        if self.messages[0].type == MessageType.keyExchange {
            processKeyExchangeMessage(self.messages[0])
        }
    }

    func insertAll(messages: [Message]) {
        // Chat room is created
        if messages.isEmpty, let publicKeyBundles = chatRoomFacade?.getPublicKeyBundles(of: members) {
            performKeyExchange(publicKeyBundles: publicKeyBundles)
        }

        var newMessages = self.messages.filter({ $0.receiverId == ChatRoom.allUsersId || $0.receiverId == self.id })
        newMessages.sort(by: { $0.creationTime < $1.creationTime })

        if !newMessages.isEmpty && newMessages[0].type == MessageType.keyExchange {
            processKeyExchangeMessage(newMessages[0])
        }

        self.messages = newMessages
    }

    private func performKeyExchange(publicKeyBundles: [String: Data]) {
        for member in members where member.id != currentUser.id {
            guard let bundleData = publicKeyBundles[member.id] else {
                // Replace fatalError with something else
                fatalError("Member public key bundle not available")
            }

            guard let keyExchangeBundleData = try? groupCryptographyProvider
                    .generateKeyExchangeDataFrom(serverKeyBundleData: bundleData, groupId: self.id) else {
                // Replace fatalError with something else
                fatalError("Unable to generate key exchange bundle for chat room member")
            }

            storeMessage(message: Message(senderId: currentUser.id,
                                          content: keyExchangeBundleData,
                                          type: MessageType.keyExchange,
                                          receiverId: member.id))
        }
    }

    private func processKeyExchangeMessage(_ message: Message) {
        do {
            try groupCryptographyProvider.process(keyExchangeBundleData: message.content, groupId: self.id)
        } catch {
            // Replace fatalError with something else
            fatalError("Unable to process key exchange bundle from group creator")
        }
    }

    func remove(message: Message) {
        if let index = messages.firstIndex(of: message) {
            self.messages.remove(at: index)
        }
    }

    func update(message: Message) {
        if let index = messages.firstIndex(of: message) {
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
}

extension ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
