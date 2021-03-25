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
    private var chatRoomsListener: ListenerRegistration?
    private var usersReference: CollectionReference?
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
                os_log("Error loading users: \(error?.localizedDescription ?? "No error")")
                return
            }
            let users: [User] = snapshot.documents.compactMap {
                FirebaseUserFacade.convert(document: $0)
            }
            self.delegate?.insertAll(users: users)
            onCompletion?()
        }
    }

    private func loadChatRooms(onCompletion: (() -> Void)?) {
        chatRoomsReference = db
            .collection(DatabaseConstant.Collection.chatRooms)
        userChatRoomPairsReference = db.collection(DatabaseConstant.Collection.modules)
            .document(moduleId)
            .collection(DatabaseConstant.Collection.userChatRoomPairs)
        userChatRoomPairsFilteredQuery = userChatRoomPairsReference?
            .whereField(DatabaseConstant.UserChatRoomPair.userId, isEqualTo: userId)
        userChatRoomPairsFilteredQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            let chatRooms = snapshot.documents
                .compactMap({
                    FirebaseChatRoomFacade.convert(document: $0)
                })
            self.delegate?.insertAll(chatRooms: chatRooms)
            onCompletion?()
        }
    }

    private func addListeners() {
        chatRoomsListener = userChatRoomPairsFilteredQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleChatRoomDocumentChange(change)
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

    }

    func save(_ chatRoom: ChatRoom) {
        userChatRoomPairsReference?.addDocument(data: FirebaseChatRoomFacade.convert(chatRoom: chatRoom)) { error in
            if let e = error {
                os_log("Error sending chatRoom: \(e.localizedDescription)")
                return
            }
        }
    }

    private func handleChatRoomDocumentChange(_ change: DocumentChange) {
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
                    os_log("Error getting sender in message: \(err.localizedDescription)")
                    return
                }

                let user: User = FirebaseUserFacade.convert(document: snapshot)
                switch change.type {
                case .added:
                    self.delegate?.insert(user: user)
                default:
                    break
                }
            })
    }

}
