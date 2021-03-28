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
    var users: [User] {
        didSet {
            for user in users {
                self.userIdsToUsers[user.id] = user
            }
        }
    }
    private var moduleFacade: ModuleFacade?
    var userIdsToUsers: [String: User] = [:] {
        didSet {
            for chatRoom in chatRooms {
                chatRoom.setUserIdsToUsers(self.userIdsToUsers)
            }
        }
    }

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.users = []
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    init(name: String, users: [User], profilePictureUrl: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.users = users
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
}

// MARK: ModuleFacadeDelegate
extension Module: ModuleFacadeDelegate {
    func insert(chatRoom: ChatRoom) {
        guard !self.chatRooms.contains(chatRoom) else {
            return
        }
        chatRoom.setChatRoomConnection()
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
        guard self.userIdsToUsers[user.id] == nil else {
            return
        }
        self.userIdsToUsers[user.id] = user
    }

    func update(user: User) {
        if self.userIdsToUsers[user.id] != nil {
            self.userIdsToUsers[user.id] = user
        }
    }

    func remove(user: User) {
        userIdsToUsers[user.id] = nil
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
