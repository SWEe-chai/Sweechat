//
//  FirebaseUserChatRoomPair.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserChatRoomModulePair {
    let userId: String
    let chatRoomId: Identifier<ChatRoom>
    let moduleId: Identifier<Module>
    let permissions: UInt32

    init(userId: String, chatRoomId: Identifier<ChatRoom>, moduleId: Identifier<Module>, permissions: UInt32) {
        self.userId = userId
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
