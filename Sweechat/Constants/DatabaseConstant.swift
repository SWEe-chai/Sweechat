//
//  DatabaseConstant.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/3/21.
//

struct DatabaseConstant {
    struct Collection {
        static let chatRooms = "chatRooms"
        static let messages = "messages"
    }

    struct Message {
        static let creationTime = "creationTime"
        static let senderId = "senderId"
        static let content = "content"
    }

    struct User {
        static let id = "userid"
        static let name = "name"
        static let photo = "photo"
    }
}
