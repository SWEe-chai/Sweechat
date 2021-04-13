//
//  FirebaseUserChatRoomPair.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserChatRoomModulePair {
    let userId: Identifier<User>
    let chatRoomId: Identifier<ChatRoom>
    let moduleId: Identifier<Module>
    let permissions: UInt32

    init(userId: Identifier<User>, chatRoomId: Identifier<ChatRoom>, moduleId: Identifier<Module>, permissions: UInt32) {
        self.userId = userId
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
