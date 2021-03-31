//
//  FirebaseUserChatRoomPair.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserChatRoomModulePair {
    let userId: String
    let chatRoomId: String
    let moduleId: String
    let permissions: UInt32

    init(userId: String, chatRoomId: String, moduleId: String, permissions: UInt32) {
        self.userId = userId
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
