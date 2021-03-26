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
    var name: String
    var profilePictureUrl: String?
    @Published var messages: [Message] {
        willSet {
            objectWillChange.send()
        }
    }
    private var chatRoomFacade: ChatRoomFacade
    let permissions: ChatRoomPermissionBitmask
    var members: [User]
    private var moduleUserIdsToUsers: [String: User] = [:]

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.members = []
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

    init(name: String, members: [User], profilePictureUrl: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.members = members
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

    func storeMessage(message: Message) {
        self.chatRoomFacade.save(message)
    }

    func setUserIdsToUsers(_ userIdsToUsers: [String: User]) {
        self.moduleUserIdsToUsers = userIdsToUsers
    }

    func getUser(userId: String) -> User {
        moduleUserIdsToUsers[userId] ?? User.createUnavailableUser()
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
            print("whyyyyyyyy never update")
            self.messages.remove(at: index)
            self.messages.insert(message, at: index)
            print(self.messages[0].content)
        }
        self.messages.sort(by: { $0.creationTime < $1.creationTime })
    }

    func insert(member: User) {
        guard !self.members.contains(member) else {
            return
        }
        self.members.append(member)
    }

    func remove(member: User) {
        if let index = members.firstIndex(of: member) {
            self.members.remove(at: index)
        }
    }

    func insertAll(members: [User]) {
        self.members = members
    }
}

extension ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
