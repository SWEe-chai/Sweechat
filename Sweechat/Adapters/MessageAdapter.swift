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

      guard let creationTime = data["created"] as? Date,
            let senderId = data["senderID"] as? String else {
        return nil
      }

      let id = document.documentID

        let sender = MLSender(id: senderId)

      if let content = data["content"] as? String {
        let content = content
        return Message(id: id, sender: sender, creationTime: creationTime, content: content)
      }
        return nil
    }

}
