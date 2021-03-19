//
//  FirebaseChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

class FirebaseChatRoomFacade: ChatRoomFacade {
    weak var delegate: ChatRoomFacadeDelegate?
    private var chatRoomId: String!

    var db = Firestore.firestore()
    var reference: CollectionReference?
    private var messageListener: ListenerRegistration?

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
    }

    func loadMessages() {
        reference = db.collection(
            [
                DatabaseConstant.Collection.chatRooms,
                chatRoomId,
                DatabaseConstant.Collection.messages
            ].joined(separator: "/"))

        messageListener = reference?.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }

          snapshot.documentChanges.forEach { change in
            self.handleDocumentChange(change)
          }
        }

    }

    func save(_ message: Message) {
        reference?.addDocument(data: FirebaseMessageFacade.convert(message: message)) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let messageRep = FirebaseMessageFacade.convert(document: change.document) else {
            return
        }

        var senderRep: UserRepresentation?
        let referenceToSenderDocument = db
            .collection(DatabaseConstant.Collection.users)
            .document(messageRep.senderId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                senderRep = FirebaseUserFacade.convert(document: snapshot)
                }
           )

        if let senderRep = senderRep {
            switch change.type {
            case .added:
                self.delegate?.insert(
                    message: Message(
                        id: messageRep.id,
                        sender: User(details: senderRep),
                        creationTime: messageRep.creationTime,
                        content: messageRep.content
                    )
                )
            default:
                break
            }
        }
    }
}
