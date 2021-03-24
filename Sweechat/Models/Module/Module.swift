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
    private var moduleFacade: ModuleFacade

    init() {
        self.id = UUID().uuidString
        self.chatRooms = []
        self.moduleFacade = FirebaseModuleFacade(moduleId: id)
        moduleFacade.delegate = self
    }

    init(id: String) {
        self.id = id
        self.chatRooms = []
        self.moduleFacade = FirebaseModuleFacade(moduleId: id)
        moduleFacade.delegate = self
    }

    func storeChatRoom(chatRoom: ChatRoom) {
        self.moduleFacade.save(chatRoom)
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
}
