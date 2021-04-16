//
//  FirebaseUserChatRoomModulePairAdapter.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/4/21.
//

import FirebaseFirestore
import os

struct FirebaseUserChatRoomModulePairAdapter {
    static func convert(document: DocumentSnapshot) -> FirebaseUserChatRoomModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userIdStr = data?[DatabaseConstant.UserChatRoomModulePair.userId] as? String,
              let chatRoomIdStr = data?[DatabaseConstant.UserChatRoomModulePair.chatRoomId] as? String,
              let moduleIdStr = data?[DatabaseConstant.UserChatRoomModulePair.moduleId] as? String,
              let permissions = data?[DatabaseConstant.UserChatRoomModulePair.permissions]
                as? ChatRoomPermissionBitmask else {
            os_log("Error converting data for UserChatRoomModulePair, data: %s", String(describing: data))
            return nil
        }

        let userId = Identifier<User>(val: userIdStr)
        let chatRoomId = Identifier<ChatRoom>(val: chatRoomIdStr)
        let moduleId = Identifier<Module>(val: moduleIdStr)
        return FirebaseUserChatRoomModulePair(
            userId: userId,
            chatRoomId: chatRoomId,
            moduleId: moduleId,
            permissions: permissions)
    }

    static func convert(pair: FirebaseUserChatRoomModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserChatRoomModulePair.userId: pair.userId.val,
            DatabaseConstant.UserChatRoomModulePair.chatRoomId: pair.chatRoomId.val,
            DatabaseConstant.UserChatRoomModulePair.moduleId: pair.moduleId.val,
            DatabaseConstant.UserChatRoomModulePair.permissions: pair.permissions
        ]
    }
}
