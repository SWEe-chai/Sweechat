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
    private var userChatRoomModulePairsReference: CollectionReference?
    private var currentUserChatRoomsQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?
    private var usersReference: CollectionReference?
    private var usersListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentModuleUsersQuery: Query?
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
        usersReference = db.collection(DatabaseConstant.Collection.users)
        userModulePairsReference = db
            .collection(DatabaseConstant.Collection.userModulePairs)
        currentModuleUsersQuery = userModulePairsReference?
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId)
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId)
        loadUsers(onCompletion: { self.loadChatRooms(onCompletion: self.addListeners) })
    }

    private func loadUsers(onCompletion: (() -> Void)?) {
        currentModuleUsersQuery?.getDocuments { querySnapshot, error in
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
        currentUserChatRoomsQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                let data = document.data()
                guard let chatRoomId = data[DatabaseConstant.UserChatRoomModulePair.chatRoomId] as? String else {
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
        userChatRoomModulePairsListener = currentUserChatRoomsQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserChatRoomModulePairDocumentChange(change)
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
        chatRoomsReference?
            .document(chatRoom.id)
            .setData(FirebaseChatRoomFacade.convert(chatRoom: chatRoom)) { error in
                if let e = error {
                    os_log("Error sending chatRoom: \(e.localizedDescription)")
                    return
                }
            }
        for member in chatRoom.members {
            let pair = FirebaseUserChatRoomModulePair(userId: member.id, chatRoomId: chatRoom.id, moduleId: moduleId)
            userChatRoomModulePairsReference?.addDocument(data: FirebaseUserChatRoomModulePairFacade.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    private func handleUserChatRoomModulePairDocumentChange(_ change: DocumentChange) {
        guard let firebaseUserChatRoomPair = FirebaseUserChatRoomModulePairFacade.convert(document: change.document) else {
            return
        }
        self.db
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(firebaseUserChatRoomPair.chatRoomId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting chat room in module: \(err.localizedDescription)")
                    return
                }

                if let chatRoom = FirebaseChatRoomFacade.convert(document: snapshot) {
                    switch change.type {
                    case .added:
                        self.delegate?.insert(chatRoom: chatRoom)
                    case .removed:
                        self.delegate?.remove(chatRoom: chatRoom)
                    default:
                        break
                    }
                }
            })
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let userChatRoomModulePair = FirebaseUserChatRoomModulePairFacade.convert(document: change.document) else {
            return
        }
        self.db
            .collection(DatabaseConstant.Collection.users)
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
                    self.delegate?.insert(user: user)
                case .removed:
                    self.delegate?.remove(user: user)
                default:
                    break
                }
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
