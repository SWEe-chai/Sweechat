//
//  DatabaseConstant.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/3/21.
//

import Foundation

struct DatabaseConstant {
    struct Collection {
        static let chatRooms = "chatRooms"
        static let messages = "messages"
        static let users = "users"
        static let modules = "modules"
        static let userModulePairs = "userModulePairs"
        static let userChatRoomModulePairs = "userChatRoomModulePairs"
    }

    struct UserModulePair {
        static let moduleId = "moduleId"
        static let userId = "userId"
    }

    struct UserChatRoomModulePair {
        static let userId = "userId"
        static let chatRoomId = "chatRoomId"
        static let moduleId = "moduleId"
    }

    struct Module {
        static let id = "id"
        static let name = "name"
        static let profilePictureUrl = "profilePictureUrl"
    }
    
    struct ChatRoom {
        static let id = "id"
        static let name = "name"
        static let profilePictureUrl = "profilePictureUrl"
    }

    struct User {
        static let id = "id"
        static let name = "name"
        static let profilePictureUrl = "profilePictureUrl"
    }

    struct Message {
        static let creationTime = "creationTime"
        static let senderId = "senderId"
        static let content = "content"
    }
}
