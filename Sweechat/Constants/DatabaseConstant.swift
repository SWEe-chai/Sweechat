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
    }

    struct User {
        static let id = "id"
        static let name = "name"
        static let profilePictureURL = "profilePictureURL"
    }

    struct Message {
        static let creationTime = "creationTime"
        static let senderId = "senderId"
        static let content = "content"
    }
}
