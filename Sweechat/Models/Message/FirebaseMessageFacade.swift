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
              let senderId = data?[DatabaseConstant.Message.senderId] as? String else {
            return nil
        }

        guard let messageTypeStr = data?[DatabaseConstant.Message.type] as? String else {
            os_log("Failed to convert message type as string")
            return nil
        }

        guard let parentId = data?[DatabaseConstant.Message.parentId] as? String? else {
            os_log("Failed to convert parentId as String?")
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
            parentId: parentId)
        }
        return nil
    }

    static func convert(message: Message) -> [String: Any] {
        var map: [String: Any] =
        [
            DatabaseConstant.Message.creationTime: message.creationTime,
            DatabaseConstant.Message.senderId: message.senderId,
            DatabaseConstant.Message.content: message.content,
            DatabaseConstant.Message.type: message.type.rawValue
        ]

        // This means that in Firestore, some Message document might have
        // a parentId, some might not. Non-existence of parentId is used
        // to translate it to `nil`
        if let parentId = message.parentId {
            map[DatabaseConstant.Message.parentId] = parentId
        }

        return map
    }

}
