//
//  FirebaseMessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//
import FirebaseFirestore
import os

class FirebaseMessageFacade {
    static func convert(document: DocumentSnapshot) -> Message? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let creationTime = data?[DatabaseConstant.Message.creationTime] as? Timestamp,
              let senderId = data?[DatabaseConstant.Message.senderId] as? String,
              let receiverId = data?[DatabaseConstant.Message.receiverId] as? String else {
            return nil
        }

        guard let messageTypeStr = data?[DatabaseConstant.Message.type] as? String else {
            os_log("Failed to convert message type as string")
            return nil
        }

        guard let messageType = MessageType(rawValue: messageTypeStr) else {
            os_log("Unable to initialise MessageType enum")
            return nil
        }

        let id = document.documentID
        if let content = data?[DatabaseConstant.Message.content] as? Data {
        return Message(
            id: id,
            senderId: senderId,
            creationTime: creationTime.dateValue(),
            content: content,
            type: messageType,
            receiverId: receiverId)
        }
        return nil
    }

    static func convert(message: Message) -> [String: Any] {
        [
            DatabaseConstant.Message.creationTime: message.creationTime,
            DatabaseConstant.Message.senderId: message.senderId,
            DatabaseConstant.Message.content: message.content,
            DatabaseConstant.Message.type: message.type.rawValue,
            DatabaseConstant.Message.receiverId: message.receiverId
        ]
    }
}
