//
//  Module.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

import Combine
import Foundation

class Module: ObservableObject {
    var id: String
    @Published var name: String
    var profilePictureUrl: String?
    @Published var chatRooms: [ChatRoom]
    @Published var members: [User] {
        didSet {
            for user in members {
                self.userIdsToUsers[user.id] = user
            }
        }
    }
    private var moduleFacade: ModuleFacade?
    var userIdsToUsers: [String: User] = [:]

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = []
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    init(name: String, users: [User], profilePictureUrl: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = users
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    func update(module: Module) {
        self.name = module.name
        self.profilePictureUrl = module.profilePictureUrl
    }

    func setModuleConnectionFor(_ userId: String) {
        self.moduleFacade = FirebaseModuleFacade(moduleId: self.id, userId: userId)
        self.moduleFacade?.delegate = self
    }

    func store(chatRoom: ChatRoom) {
        self.moduleFacade?.save(chatRoom: chatRoom)
    }

    func store(user: User) {
        self.moduleFacade?.save(user: user)
    }

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    func subscribeToChatrooms(function: @escaping ([ChatRoom]) -> Void) -> AnyCancellable {
        $chatRooms.sink(receiveValue: function)
    }

    func subscribeToMembers(function: @escaping ([User]) -> Void) -> AnyCancellable {
        $members.sink(receiveValue: function)
    }
}

// MARK: ModuleFacadeDelegate
extension Module: ModuleFacadeDelegate {
    func insert(chatRoom: ChatRoom) {
        guard !self.chatRooms.contains(chatRoom) else {
            return
        }
        chatRoom.setChatRoomConnection()
        print("setting up chatroom connection")
        self.chatRooms.append(chatRoom)
    }

    func insertAll(chatRooms: [ChatRoom]) {
        chatRooms.forEach { $0.setChatRoomConnection() }
        self.chatRooms = chatRooms
    }

    func update(chatRoom: ChatRoom) {
        if let index = chatRooms.firstIndex(of: chatRoom) {
            self.chatRooms[index].update(chatRoom: chatRoom)
        }
    }

    func remove(chatRoom: ChatRoom) {
        if let index = chatRooms.firstIndex(of: chatRoom) {
            self.chatRooms.remove(at: index)
        }
    }

    func insert(user: User) {
        guard !self.members.contains(user) else {
            return
        }
        user.setUserConnection()
        self.members.append(user)
    }

    func update(user: User) {
        if let index = members.firstIndex(of: user) {
            self.members[index].update(user: user)
        }
    }

    func remove(user: User) {
        if let index = members.firstIndex(of: user) {
            self.members.remove(at: index)
        }
    }

    func insertAll(users: [User]) {
        for user in users {
            self.userIdsToUsers[user.id] = user
        }
    }
}

extension Module: Equatable {
    static func == (lhs: Module, rhs: Module) -> Bool {
        lhs.id == rhs.id
    }
}
