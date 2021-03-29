//
//  ChatRoom.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//
import Combine
import Foundation

class ChatRoom: ObservableObject {
    var id: String
    @Published var name: String
    var profilePictureUrl: String?
    @Published var messages: [Message]
    private var chatRoomFacade: ChatRoomFacade?
    let permissions: ChatRoomPermissionBitmask
    private var moduleUserIdsToUsers: [String: User] = [:]
    var members: [User] {
        Array(moduleUserIdsToUsers.values)
    }

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.permissions = ChatRoomPermission.none
    }

    init(name: String, members: [User], profilePictureUrl: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.permissions = ChatRoomPermission.none
        insertAll(members: members)
    }

    func setChatRoomConnection() {
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade?.delegate = self
    }

    func storeMessage(message: Message) {
        self.chatRoomFacade?.save(message)
    }

    func setUserIdsToUsers(_ userIdsToUsers: [String: User]) {
        self.moduleUserIdsToUsers = userIdsToUsers
    }

    func getUser(userId: String) -> User {
        moduleUserIdsToUsers[userId] ?? User.createUnavailableUser()
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
}

// MARK: ChatRoomFacadeDelegate
extension ChatRoom: ChatRoomFacadeDelegate {
    func insert(message: Message) {
        guard !self.messages.contains(message) else {
            return
        }
        self.messages.append(message)
        self.messages.sort(by: { $0.creationTime < $1.creationTime })
    }

    func insertAll(messages: [Message]) {
        let newMessages = messages.sorted(by: { $0.creationTime < $1.creationTime })
        self.messages = newMessages
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
        moduleUserIdsToUsers[member.id] = member
    }

    func remove(member: User) {
        if !moduleUserIdsToUsers.keys.contains(member.id) {
            return
        }
        moduleUserIdsToUsers.removeValue(forKey: member.id)
    }

    func insertAll(members: [User]) {
        for member in members {
            moduleUserIdsToUsers[member.id] = member
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
