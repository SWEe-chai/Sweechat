//
//  MessageAdapter.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation
import FirebaseFirestore

class MessageAdapter {
    static func convert(document: QueryDocumentSnapshot) -> Message? {
        let data = document.data()

        guard let creationTime = data[DatabaseConstant.Message.creationTime] as? Timestamp,
              let senderId = data[DatabaseConstant.Message.senderId] as? String else {
        return nil
        }

        let id = document.documentID

        let sender = MLSender(id: senderId)

        if let content = data[DatabaseConstant.Message.content] as? String {
        return Message(id: id, sender: sender, creationTime: creationTime.dateValue(), content: content)
        }
        return nil
    }

    static func convert(message: Message) -> [String: Any] {
        [
            DatabaseConstant.Message.creationTime: message.creationTime,
            DatabaseConstant.Message.senderId: message.sender.id,
            DatabaseConstant.Message.content: message.content
        ]
    }
}
