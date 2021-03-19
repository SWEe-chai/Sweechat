//
//  FirebaseMessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//
import FirebaseFirestore

class FirebaseMessageFacade: MessageFacade {
    static var db = Firestore.firestore()
    static var reference: DocumentReference?

    static func convert(document: QueryDocumentSnapshot) -> Message? {
        let data = document.data()

        guard let creationTime = data[DatabaseConstant.Message.creationTime] as? Timestamp,
              let senderId = data[DatabaseConstant.Message.senderId] as? String else {
            return nil
        }

        let id = document.documentID
        guard let senderDetails = FirebaseUserFacade.getUserDetails(userId: senderId) else {
            return nil
        }
        let sender = User(details: senderDetails)

        if let content = data[DatabaseConstant.Message.content] as? String {
        return Message(id: id, sender: sender, creationTime: creationTime.dateValue(), content: content)
        }
        return nil
    }

}
