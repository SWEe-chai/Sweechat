//
//  ChatRoom.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import Foundation

struct ChatRoom {
    var id: String
    var messages: [Message]
    let permissions: ChatRoomPermissionBitmask
    
    init() {
        self.id = UUID().uuidString
        self.messages = []
        self.permissions = ChatRoomPermission.none
    }
    
    init(id: String) {
        self.id = id
        self.messages = []
        self.permissions = ChatRoomPermission.none
    }
}
