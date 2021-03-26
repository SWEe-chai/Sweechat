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

    init(userId: String, chatRoomId: String, moduleId: String) {
        self.userId = userId
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
    }
}
