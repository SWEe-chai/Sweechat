//
//  FirebaseModuleFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

import FirebaseFirestore
import os

class FirebaseModuleFacade: ModuleFacade {
    weak var delegate: ModuleFacadeDelegate?
    private var moduleId: String
    private var userId: String

    private var db = Firestore.firestore()
    private var chatRoomsReference: CollectionReference?
    private var userChatRoomPairsReference: CollectionReference?
    private var userChatRoomPairsFilteredQuery: Query?
    private var userChatRoomPairsListener: ListenerRegistration?
    private var usersReference: CollectionReference?
    private var usersListener: ListenerRegistration?
    private var userModulePairs: CollectionReference?
    private var userModulePairsFilteredQuery: Query?
    private var userModulePairsListener: ListenerRegistration?

    init(moduleId: String, userId: String) {
        self.moduleId = moduleId
        self.userId = userId
        setUpConnectionToModule()
    }

    func setUpConnectionToModule() {
        if moduleId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        loadUsers(onCompletion: { self.loadChatRooms(onCompletion: self.addListeners) })
    }

    private func loadUsers(onCompletion: (() -> Void)?) {
        usersReference = db.collection(DatabaseConstant.Collection.users)
        userModulePairs = db
            .collection(DatabaseConstant.Collection.userModulePairs)
        userModulePairsFilteredQuery = userModulePairs?
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId)
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId)
        userModulePairsFilteredQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading user module pairs: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                let data = document.data()
                guard let userId = data[DatabaseConstant.UserModulePair.userId] as? String else {
                    return
                }
                self.db
                    .collection(DatabaseConstant.Collection.users)
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
                        self.delegate?.insert(user: user)
                    })
            }
            onCompletion?()
        }
    }

    private func loadChatRooms(onCompletion: (() -> Void)?) {
        chatRoomsReference = db
            .collection(DatabaseConstant.Collection.chatRooms)
        userChatRoomPairsReference = db
            .collection(DatabaseConstant.Collection.userChatRoomPairs)
        userChatRoomPairsFilteredQuery = userChatRoomPairsReference?
            .whereField(DatabaseConstant.UserChatRoomPair.userId, isEqualTo: userId)
        userChatRoomPairsFilteredQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                let data = document.data()
                guard let chatRoomId = data[DatabaseConstant.UserChatRoomPair.chatRoomId] as? String else {
                    return
                }
                self.db
                    .collection(DatabaseConstant.Collection.chatRooms)
                    .document(chatRoomId)
                    .getDocument(completion: { documentSnapshot, error in
                        guard let snapshot = documentSnapshot else {
                            return
                        }
                        if let err = error {
                            os_log("Error getting chat rooms in module: \(err.localizedDescription)")
                            return
                        }

                        if let chatRoom = FirebaseChatRoomFacade.convert(document: snapshot) {
                            self.delegate?.insert(chatRoom: chatRoom)
                        }
                    }
                    )
            }
            onCompletion?()
        }
    }

    private func addListeners() {
        userChatRoomPairsListener = userChatRoomPairsFilteredQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserChatRoomPairDocumentChange(change)
            }
        }
        userModulePairsListener = userModulePairsFilteredQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
            }
        }

        usersListener = usersReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserDocumentChange(change)
            }
        }
    }

    func save(_ chatRoom: ChatRoom) {
        chatRoomsReference?.addDocument(data: FirebaseChatRoomFacade.convert(chatRoom: chatRoom)) { error in
            if let e = error {
                os_log("Error sending chatRoom: \(e.localizedDescription)")
                return
            }
        }
        for member in chatRoom.members {
            let pair = FirebaseUserChatRoomPair(userId: member.id, chatRoomId: chatRoom.id)
            userChatRoomPairsReference?.addDocument(data: FirebaseUserChatRoomPairFacade.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    private func handleUserChatRoomPairDocumentChange(_ change: DocumentChange) {
        guard let firebaseUserChatRoomPair = FirebaseUserChatRoomPairFacade.convert(document: change.document) else {
            return
        }
        chatRoomsReference?
            .document(firebaseUserChatRoomPair.chatRoomId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting sender in message: \(err.localizedDescription)")
                    return
                }

                if let chatRoom: ChatRoom = FirebaseChatRoomFacade.convert(document: snapshot) {
                    switch change.type {
                    case .added:
                        self.delegate?.insert(
                            chatRoom: chatRoom
                        )
                    default:
                        break
                    }
                }
            })
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let userModulePair = FirebaseUserModulePairFacade.convert(document: change.document) else {
            return
        }
        userModulePairs?
            .document(userModulePair.userId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting handling user change in module: \(err.localizedDescription)")
                    return
                }
                self.db
                    .collection(DatabaseConstant.Collection.users)
                    .document(userModulePair.userId)
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
                            self.delegate?.insert(user: user)
                        case .removed:
                            self.delegate?.remove(user: user)
                        default:
                            break
                        }
                    })
            })
    }

    private func handleUserDocumentChange(_ change: DocumentChange) {
        let user = FirebaseUserFacade.convert(document: change.document)
        usersReference?
            .document(user.id)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting sender in message: \(err.localizedDescription)")
                    return
                }

                switch change.type {
                case .modified:
                    self.delegate?.update(user: user)
                default:
                    break
                }
            })

    }

}
