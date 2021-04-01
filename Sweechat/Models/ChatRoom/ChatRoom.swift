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
