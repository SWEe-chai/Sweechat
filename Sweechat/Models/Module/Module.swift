//
//  Module.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

import Combine
import Foundation

class Module: ObservableObject {
    static let unavailableModuleId = Identifier<Module>("")
    static let unavailableModuleName = "Unavailable Module"

    var id: Identifier<Module>
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
    var currentUser: User
    private var moduleFacade: ModuleFacade?
    var userIdsToUsers: [String: User] = [:]
    let currentUserPermission: ModulePermissionBitmask

    static func createUnavailableModule() -> Module {
        Module(
            id: unavailableModuleId,
            name: unavailableModuleName,
            currentUser: User.createUnavailableUser(),
            currentUserPermission: ModulePermissionBitmask()
        )
    }

    init(id: Identifier<Module>,
         name: String,
         currentUser: User,
         currentUserPermission: ModulePermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.currentUser = currentUser
        self.currentUserPermission = currentUserPermission
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = []
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    init(name: String,
         users: [User],
         currentUser: User,
         currentUserPermission: ModulePermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = Identifier<Module>(val: UUID().uuidString)
        self.name = name
        self.currentUser = currentUser
        self.currentUserPermission = currentUserPermission
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = users
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    func setModuleConnection() {
        self.moduleFacade = FirebaseModuleFacade(
            moduleId: self.id,
            user: currentUser)
        self.moduleFacade?.delegate = self
    }

    func store(chatRoom: ChatRoom, userPermissions: [UserPermissionPair], onCompletion: (() -> Void)? = nil) {
        assert(chatRoom.members.count == userPermissions.count)
        self.moduleFacade?.save(
            chatRoom: chatRoom,
            userPermissions: userPermissions,
            onCompletion: onCompletion)
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
        guard !self.chatRooms.contains(chatRoom),
              chatRoom as? ThreadChatRoom == nil else {
            return
        }
        chatRoom.setChatRoomConnection()
        self.chatRooms.append(chatRoom)
    }

    func insertAll(chatRooms: [ChatRoom]) {
        let newChatRooms = chatRooms.filter({ $0 as? ThreadChatRoom == nil }).filter({ !chatRooms.contains($0) })
        newChatRooms.forEach { $0.setChatRoomConnection() }
        self.chatRooms.append(contentsOf: newChatRooms)
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

    func update(module: Module) {
        self.name = module.name
        self.profilePictureUrl = module.profilePictureUrl
    }
}

extension Module: Equatable {
    static func == (lhs: Module, rhs: Module) -> Bool {
        lhs.id == rhs.id
    }
}
