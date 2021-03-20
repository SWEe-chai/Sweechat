//
//  FirebaseChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore
import os

class FirebaseChatRoomFacade: ChatRoomFacade {
    weak var delegate: ChatRoomFacadeDelegate?
    private var chatRoomId: String!

    var db = Firestore.firestore()
    var reference: CollectionReference?
    private var messageListener: ListenerRegistration?

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        loadMessages()
    }

    func loadMessages() {
        reference = db.collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId)
            .collection(DatabaseConstant.Collection.messages)

        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
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
                os_log("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let messageRep = FirebaseMessageFacade.convert(document: change.document) else {
            return
        }
        guard !messageRep.senderId.isEmpty else {
            os_log("Error reading message: Message senderId is empty")
            return
        }
        db
            .collection(DatabaseConstant.Collection.users)
            .document(messageRep.senderId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting sender in message: \(err.localizedDescription)")
                    return
                }

                var user: User!
                if let senderRep = FirebaseUserFacade.convert(document: snapshot) {
                    user = User(details: senderRep)
                } else {
                    user = User.createDeletedUser()
                }

                switch change.type {
                case .added:
                    self.delegate?.insert(
                        message: Message(
                            id: messageRep.id,
                            sender: user,
                            creationTime: messageRep.creationTime,
                            content: messageRep.content
                        )
                    )
                default:
                    break
                }
            })
    }
}
