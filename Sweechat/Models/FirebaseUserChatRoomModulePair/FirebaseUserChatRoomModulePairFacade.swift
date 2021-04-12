//
//  FirebaseUserChatRoomPairDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

import FirebaseFirestore
import os

class FirebaseUserChatRoomModulePairFacade {
    static func convert(document: DocumentSnapshot) -> FirebaseUserChatRoomModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userId = data?[DatabaseConstant.UserChatRoomModulePair.userId] as? String,
              let chatRoomIdStr = data?[DatabaseConstant.UserChatRoomModulePair.chatRoomId] as? String,
              let moduleId = data?[DatabaseConstant.UserChatRoomModulePair.moduleId] as? String,
              let permissions = data?[DatabaseConstant.UserChatRoomModulePair.permissions]
                as? ChatRoomPermissionBitmask else {
            os_log("Error converting data for UserChatRoomModulePair, data: %s", String(describing: data))
            return nil
        }

        let chatRoomId = Identifier<ChatRoom>(val: chatRoomIdStr)
        return FirebaseUserChatRoomModulePair(
            userId: userId,
            chatRoomId: chatRoomId,
            moduleId: moduleId,
            permissions: permissions)
    }

    static func convert(pair: FirebaseUserChatRoomModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserChatRoomModulePair.userId: pair.userId,
            DatabaseConstant.UserChatRoomModulePair.chatRoomId: pair.chatRoomId.val,
            DatabaseConstant.UserChatRoomModulePair.moduleId: pair.moduleId,
            DatabaseConstant.UserChatRoomModulePair.permissions: pair.permissions
        ]
    }
}
