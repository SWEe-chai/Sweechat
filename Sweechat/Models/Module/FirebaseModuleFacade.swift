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
    private var userIdsToUsers: [String: User] = [:]
    private var chatRoomsReference: CollectionReference?
    private var chatRoomsListener: ListenerRegistration?
    private var usersReference: CollectionReference?
    private var usersListener: ListenerRegistration?

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
        usersReference = db
            .collection(DatabaseConstant.Collection.userModulePairs)
        usersReference?
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId)
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId)
            .getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading users: \(error?.localizedDescription ?? "No error")")
                return
            }
            let users: [User] = snapshot.documents.compactMap {
                FirebaseUserFacade.convert(document: $0)
            }
            for user in users {
                self.userIdsToUsers[user.id] = user
            }
            onCompletion?()
        }
    }

    private func loadChatRooms(onCompletion: (() -> Void)?) {
        chatRoomsReference = db.collection(DatabaseConstant.Collection.modules)
            .document(moduleId)
            .collection(DatabaseConstant.Collection.userChatRoomPairs)
        chatRoomsReference?
            .whereField(DatabaseConstant.UserChatRoomPair.userId, isEqualTo: userId)
            .getDocuments { querySnapshot, error in
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
        chatRoomsListener = chatRoomsReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleChatRoomDocumentChange(change)
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
    }

    private func handleChatRoomDocumentChange(_ change: DocumentChange) {
        guard let chatRoom = FirebaseChatRoomFacade.convert(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            self.delegate?.insert(
                chatRoom: ChatRoom(
                    id: chatRoom.id,
                    name: chatRoom.name,
                    profilePictureUrl: chatRoom.profilePictureUrl
                )
            )
        default:
            break
        }
    }
}
