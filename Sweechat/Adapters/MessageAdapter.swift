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
        print(data)
        print("Im here")
      guard let creationTime = data["creationTime"] as? Timestamp,
            let senderId = data["senderId"] as? String else {
        return nil
      }
        print("Im not here")

      let id = document.documentID

        let sender = MLSender(id: senderId)

      if let content = data["content"] as? String {
        let content = content
        return Message(id: id, sender: sender, creationTime: creationTime.dateValue(), content: content)
      }
        return nil
    }

    static func convert(message: Message) -> [String: Any] {
        [
            "creationTime": message.creationTime,
            "senderId": message.sender.id,
            "content": message.content
        ]
    }
}
