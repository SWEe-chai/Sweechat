//
//  FirebaseUserChatRoomPairDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

import FirebaseFirestore
import os

class FirebaseUserChatRoomPairFacade {
    private var db = Firestore.firestore()
    private var reference: DocumentReference?

    static func convert(document: DocumentSnapshot) -> FirebaseUserChatRoomPair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userId = data?[DatabaseConstant.UserChatRoomPair.userId] as? String,
              let chatRoomId = data?[DatabaseConstant.UserChatRoomPair.chatRoomId] as? String else {
            return nil
        }

        return FirebaseUserChatRoomPair(userId: userId, chatRoomId: chatRoomId)
    }

    static func convert(firebaseUserChatRoomPair: FirebaseUserChatRoomPair) -> [String: Any] {
        [
            DatabaseConstant.UserChatRoomPair.userId: firebaseUserChatRoomPair.userId,
            DatabaseConstant.UserChatRoomPair.chatRoomId: firebaseUserChatRoomPair.chatRoomId
        ]
    }
}
