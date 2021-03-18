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
        static let modules = "modules"
    }

    struct Message {
        static let creationTime = "creationTime"
        static let senderId = "senderId"
        static let content = "content"
    }

    struct Module {
        static let defaultModuleName = "CS3217 (Default)"
    }
}
