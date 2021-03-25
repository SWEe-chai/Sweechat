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
    private var moduleId: String

    private var db = Firestore.firestore()
    private var messagesReference: CollectionReference?
    private var messagesListener: ListenerRegistration?
    private var usersReference: CollectionReference?
    private var usersListener: ListenerRegistration?

    init(moduleId: String, chatRoomId: String) {
        self.chatRoomId = chatRoomId
        self.moduleId = moduleId
        setUpConnectionToChatRoom()
    }

    func setUpConnectionToChatRoom() {
        if chatRoomId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        self.loadMessages(onCompletion: self.addListeners)
    }

//    private func loadUsers(onCompletion: (() -> Void)?) {
//        usersReference = db.collection(DatabaseConstant.Collection.users)
//        usersReference?.getDocuments { querySnapshot, error in
//            guard let snapshot = querySnapshot else {
//                os_log("Error loading users: \(error?.localizedDescription ?? "No error")")
//                return
//            }
//            let users: [User] = snapshot.documents.compactMap {
//                FirebaseUserFacade.convert(document: $0)
//            }
//            for user in users {
//                self.userIdsToUsers[user.id] = user
//            }
//            onCompletion?()
//        }
//    }

    private func loadMessages(onCompletion: (() -> Void)?) {
        messagesReference = db
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId)
            .collection(DatabaseConstant.Collection.messages)
        messagesReference?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                return
            }
            let messages = snapshot.documents.compactMap({
                FirebaseMessageFacade.convert(document: $0)
            })
            self.delegate?.insertAll(messages: messages)
            onCompletion?()
        }
    }

    private func addListeners() {
        messagesListener = messagesReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleMessageDocumentChange(change)
            }
        }
    }

    func save(_ message: Message) {
        messagesReference?.addDocument(data: FirebaseMessageFacade.convert(message: message)) { error in
            if let e = error {
                os_log("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }

    private func handleMessageDocumentChange(_ change: DocumentChange) {
        guard let message = FirebaseMessageFacade.convert(document: change.document) else {
            return
        }
        guard !message.senderId.isEmpty else {
            os_log("Error reading message: Message senderId is empty")
            return
        }
        switch change.type {
        case .added:
            self.delegate?.insert(message: message)
        default:
            break
        }
    }

    static func convert(document: DocumentSnapshot) -> ChatRoom? {
        if !document.exists {
            os_log("Error: Cannot convert user, user document does not exist")
            return nil
        }
        let data = document.data()
        guard let id = data?[DatabaseConstant.ChatRoom.id] as? String,
              let name = data?[DatabaseConstant.ChatRoom.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for user")
            return nil
        }
        return ChatRoom(
            id: id,
            name: name,
            profilePictureUrl: profilePictureUrl
        )
    }

    static func convert(chatRoom: ChatRoom) -> [String: Any] {
        [
            DatabaseConstant.ChatRoom.id: chatRoom.id,
            DatabaseConstant.ChatRoom.name: chatRoom.name,
            DatabaseConstant.ChatRoom.profilePictureUrl: chatRoom.profilePictureUrl ?? ""
        ]

    }

}
