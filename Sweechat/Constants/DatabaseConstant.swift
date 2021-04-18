//
//  DatabaseConstant.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/3/21.
//

import Foundation

struct DatabaseConstant {
    struct Collection {
        static let environmentCollection = "environment"
        static let dev = "star-modules"
        // Change environmentDocument as needed when working on features
        // involving a schema change
        static let environmentDocument = "token-bug-2"

        static let chatRooms = "chatRooms"
        static let messages = "messages"
        static let users = "users"
        static let modules = "modules"
        static let userModulePairs = "userModulePairs"
        static let userChatRoomModulePairs = "userChatRoomModulePairs"
        static let publicKeyBundles = "publicKeyBundles"
    }

    struct UserModulePair {
        static let moduleId = "moduleId"
        static let userId = "userId"
        static let permissions = "permissions"
    }

    struct UserChatRoomModulePair {
        static let userId = "userId"
        static let chatRoomId = "chatRoomId"
        static let moduleId = "moduleId"
        static let permissions = "permissions"
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
        static let type = "type"
        static let ownerId = "ownerId"
        static let isStarred = "isStarred"
    }

    struct User {
        static let id = "id"
        static let name = "name"
        static let profilePictureUrl = "profilePictureUrl"
        static let token = "token"
    }

    struct Message {
        static let creationTime = "creationTime"
        static let senderId = "senderId"
        static let content = "content"
        static let type = "type"
        static let receiverId = "receiverId"
        static let parentId = "parentId"
        static let likers = "likers"
    }

    struct PublicKeyBundle {
        static let userId = "userId"
        static let bundleData = "bundleData"
    }
}
