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

        guard let creationTime = data[DatabaseConstant.creationTime] as? Timestamp,
              let senderId = data[DatabaseConstant.senderId] as? String else {
        return nil
        }

        let id = document.documentID

        let sender = MLSender(id: senderId)

        if let content = data[DatabaseConstant.content] as? String {
        return Message(id: id, sender: sender, creationTime: creationTime.dateValue(), content: content)
        }
        return nil
    }

    static func convert(message: Message) -> [String: Any] {
        [
            DatabaseConstant.creationTime: message.creationTime,
            DatabaseConstant.senderId: message.sender.id,
            DatabaseConstant.content: message.content
        ]
    }
}
