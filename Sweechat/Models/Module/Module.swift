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
    var name: String
    var profilePictureUrl: String?
    @Published var chatRooms: [ChatRoom] {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var users: [User] {
        willSet {
            objectWillChange.send()
        }
    }
    private var moduleFacade: ModuleFacade?
    var userIdsToUsers: [String: User] = [:]

    static func of(id: String, name: String, profilePictureUrl: String? = nil, for user: User) -> Module {
        let module = Module()
        module.id = id
        module.name = name
        module.profilePictureUrl = profilePictureUrl
        module.moduleFacade = FirebaseModuleFacade(moduleId: id, userId: user.id)
        module.moduleFacade?.delegate = module
        return module
    }
    
    private init() {
        self.id = ""
        self.name = ""
        self.profilePictureUrl = nil
        self.chatRooms = []
        self.users = []
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }
    
    func storeChatRoom(chatRoom: ChatRoom) {
        self.moduleFacade?.save(chatRoom)
    }
}

// MARK: ModuleFacadeDelegate
extension Module: ModuleFacadeDelegate {
    func insert(chatRoom: ChatRoom) {
        guard !self.chatRooms.contains(chatRoom) else {
            return
        }
        self.chatRooms.append(chatRoom)
    }

    func insertAll(chatRooms: [ChatRoom]) {
        self.chatRooms = chatRooms
    }
    
    func insert(user: User) {
        guard self.userIdsToUsers[user.id] == nil else {
            return
        }
        self.userIdsToUsers[user.id] = user
        for chatRoom in chatRooms {
            chatRoom.setUserIdsToUsers(self.userIdToUsers)
        }
    }
    
    func insertAll(users: [User]) {
        for user in users {
            self.userIdsToUsers[user.id] = user
        }
        for chatRoom in chatRooms {
            chatRoom.setUserIdsToUsers(self.userIdToUsers)
        }
    }
}
