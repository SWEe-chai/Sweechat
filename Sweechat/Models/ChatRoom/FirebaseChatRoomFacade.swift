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
    private var messagesReference: CollectionReference?
    private var messagesListener: ListenerRegistration?
    private var userChatRoomModulePairsReference: CollectionReference?
    private var userChatRoomModulePairsFilteredQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?

    private var usersReference: CollectionReference?
    private var chatRoomReference: DocumentReference?
    private var chatRoomListener: ListenerRegistration?

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        setUpConnectionToChatRoom()
    }

    func setUpConnectionToChatRoom() {
        print("setting up connection to chatroom")
        if chatRoomId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        userChatRoomModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
        userChatRoomModulePairsFilteredQuery = userChatRoomModulePairsReference?
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId)
        messagesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId)
            .collection(DatabaseConstant.Collection.messages)
        chatRoomReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId)
        usersReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.users)
        loadMembers(onCompletion: { self.loadMessages(onCompletion: self.addListeners) })
    }

    private func loadMembers(onCompletion: (() -> Void)?) {
        userChatRoomModulePairsFilteredQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading user module pairs: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                let data = document.data()
                guard let userId = data[DatabaseConstant.UserModulePair.userId] as? String else {
                    return
                }
                self.usersReference?
                    .document(userId)
                    .getDocument(completion: { documentSnapshot, error in
                        guard let snapshot = documentSnapshot else {
                            return
                        }
                        if let err = error {
                            os_log("Error getting users in module: \(err.localizedDescription)")
                            return
                        }
                        let user = FirebaseUserFacade.convert(document: snapshot)
                        self.delegate?.insert(member: user)
                    })
            }
            onCompletion?()
        }
    }

    private func loadMessages(onCompletion: (() -> Void)?) {
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

        chatRoomListener = chatRoomReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            self.handleChatRoomDocumentChange(snapshot)
        }

        userChatRoomModulePairsListener = userChatRoomModulePairsReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
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

    private func handleChatRoomDocumentChange(_ snapshot: DocumentSnapshot) {
        guard let chatRoom = FirebaseChatRoomFacade.convert(document: snapshot) else {
            return
        }
        delegate?.update(chatRoom: chatRoom)
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
        case .modified:
            self.delegate?.update(message: message)
        case .removed:
            self.delegate?.remove(message: message)
        default:
            break
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let userChatRoomModulePair = FirebaseUserChatRoomModulePairFacade.convert(document: change.document) else {
            return
        }
        self.usersReference?
            .document(userChatRoomModulePair.userId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting users in module: \(err.localizedDescription)")
                    return
                }
                let user = FirebaseUserFacade.convert(document: snapshot)
                switch change.type {
                case .added:
                    self.delegate?.insert(member: user)
                case .removed:
                    self.delegate?.remove(member: user)
                default:
                    break
                }
            })
    }

    static func convert(document: DocumentSnapshot) -> ChatRoom? {
        if !document.exists {
            os_log("Error: Cannot convert chat room, chat room document does not exist")
            return nil
        }
        let data = document.data()
        guard let id = data?[DatabaseConstant.ChatRoom.id] as? String,
              let name = data?[DatabaseConstant.ChatRoom.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for chat room")
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
