//
//  FirebaseMessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//
import FirebaseFirestore

class FirebaseMessageFacade: MessageFacade {
    var db = Firestore.firestore()
    var reference: DocumentReference?

    static func convert(document: DocumentSnapshot) -> MessageRepresentation? {
        if !document.exists {
            print("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let creationTime = data?[DatabaseConstant.Message.creationTime] as? Timestamp,
              let senderId = data?[DatabaseConstant.Message.senderId] as? String else {
            return nil
        }

        let id = document.documentID
        if let content = data?[DatabaseConstant.Message.content] as? String {
        return MessageRepresentation(
            id: id,
            creationTime: creationTime.dateValue(), senderId: senderId,
            content: content)
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
