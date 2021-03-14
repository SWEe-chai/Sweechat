//
//  Message.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

struct Message: MLMessage {
    var id: UUID?
    var content: String
    var sentDate: Date
    var sender: MLSender
    var type: MLMessageType

//  var data: MessageData {
//    if let image = image {
//      return .photo(image)
//    } else {
//      return .text(content)
//    }
//  }
      
      var messageId: String {
        return id?.uuidString ?? UUID().uuidString
      }
      
      // var image: UIImage? = nil
      var downloadURL: URL? = nil
      
      init(user: User, content: String) {
        sender = MLSender(id: user.uid, displayName: "slackers")
        self.content = content
        sentDate = Date()
        id = nil
        type = MLMessageType.text
      }
  
//  init(user: User, image: UIImage) {
//    sender = Sender(id: user.uid, displayName: AppSettings.displayName)
//    self.image = image
//    content = ""
//    sentDate = Date()
//    id = nil
//  }
  
//  init?(document: QueryDocumentSnapshot) {
//    let data = document.data()
//
//    guard let sentDate = data["created"] as? Date else {
//      return nil
//    }
//    guard let senderID = data["senderID"] as? String else {
//      return nil
//    }
//    guard let senderName = data["senderName"] as? String else {
//      return nil
//    }
//
//    id = document.documentID
//
//    self.sentDate = sentDate
//    sender = Sender(id: senderID, displayName: senderName)
//
//    if let content = data["content"] as? String {
//      self.content = content
//      downloadURL = nil
//    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
//      downloadURL = url
//      content = ""
//    } else {
//      return nil
//    }
//  }
  
}

//extension Message: DatabaseRepresentation {
//
//  var representation: [String : Any] {
//    var rep: [String : Any] = [
//      "created": sentDate,
//      "senderID": sender.id,
//      "senderName": sender.displayName
//    ]
//
//    if let url = downloadURL {
//      rep["url"] = url.absoluteString
//    } else {
//      rep["content"] = content
//    }
//
//    return rep
//  }
//
//}

extension Message: Comparable {
  
      static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
      }
      
      static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
      }
  
}
