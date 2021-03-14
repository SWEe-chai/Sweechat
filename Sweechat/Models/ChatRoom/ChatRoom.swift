//
//  ChatRoom.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import Foundation

struct ChatRoom {
    let id: UUID?
    let messages: [Message]
    let permissions: ChatRoomPermissionBitmask
}
