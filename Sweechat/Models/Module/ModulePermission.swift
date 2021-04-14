//
//  ModulePermission.swift
//  Sweechat
//
//  Created by Christian James Welly on 6/4/21.
//

import Foundation

typealias ModulePermissionBitmask = UInt32

struct ModulePermission {
    static let none: ModulePermissionBitmask = 0
    static let all: ModulePermissionBitmask = UInt32.max
    static let privateChatRoomCreation: ModulePermissionBitmask = 0b1
    static let groupChatRoomCreation: ModulePermissionBitmask = 0b1 << 1
    static let forumCreation: ModulePermissionBitmask = 0b1 << 2
    static let starChatRoom: ModulePermissionBitmask = 0b1 << 3

    static let moduleOwner = all
    static let student = privateChatRoomCreation | groupChatRoomCreation

    static func canCreateForum(permission: ModulePermissionBitmask) -> Bool {
        permission & forumCreation != 0
    }

    static func canStarChatRoom(permission: ModulePermissionBitmask) -> Bool {
        permission & starChatRoom != 0
    }
}
