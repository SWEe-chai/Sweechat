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
    private var chatRoomId: String

    private var db = Firestore.firestore()
    private var userIdsToUsers: [String: User] = [:]
    private var chatRoomReference: CollectionReference?
    private var messageListener: ListenerRegistration?

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        setUpConnectionToChatRoom()
    }

    func setUpConnectionToChatRoom() {
        if chatRoomId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        loadUsers(onCompletion: { self.loadMessages(onCompletion: self.addListener) })
    }

    private func loadUsers(onCompletion: (() -> Void)?) {
        let usersReference = db.collection(DatabaseConstant.Collection.users)
        usersReference.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading users: \(error?.localizedDescription ?? "No error")")
                return
            }
            let userRepresentations: [UserRepresentation] = snapshot.documents.compactMap {
                FirebaseUserFacade.convert(document: $0)
            }

            for userRep in userRepresentations {
                self.userIdsToUsers[userRep.id] = User(details: userRep)
            }
            onCompletion?()
        }
    }

    private func loadMessages(onCompletion: (() -> Void)?) {
        chatRoomReference = db.collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId)
            .collection(DatabaseConstant.Collection.messages)
        chatRoomReference?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                return
            }
            let messagesRepresentations = snapshot.documents.compactMap({
                FirebaseMessageFacade.convert(document: $0)
            })
            let messages: [Message] = messagesRepresentations.compactMap { messageRep in
                let user: User = self.userIdsToUsers[messageRep.senderId] ??
                    User.createUnavailableUser()
                return Message(id: messageRep.id,
                               sender: user,
                               creationTime: messageRep.creationTime,
                               content: messageRep.content)
            }
            self.delegate?.insertAll(messages: messages)
            onCompletion?()
        }
    }

    private func addListener() {
        messageListener = chatRoomReference?.addSnapshotListener { querySnapshot, error in
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
        chatRoomReference?.addDocument(data: FirebaseMessageFacade.convert(message: message)) { error in
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

                let user: User = self.getUserFromMessageDocument(document: snapshot)
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

    private func getUserFromMessageDocument(document: DocumentSnapshot) -> User {
        if let senderRep = FirebaseUserFacade.convert(document: document) {
            return User(details: senderRep)
        } else {
            return User.createUnavailableUser()
        }
    }
}
