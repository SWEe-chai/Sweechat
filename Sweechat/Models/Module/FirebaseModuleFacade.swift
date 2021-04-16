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
    private var moduleId: Identifier<Module>
    private var user: User
    private var userId: Identifier<User> { user.id }

    private var db = Firestore.firestore()
    private var chatRoomsReference: CollectionReference?
    private var userChatRoomModulePairsReference: CollectionReference?
    private var currentUserChatRoomsQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentModuleUsersQuery: Query?
    private var userModulePairsListener: ListenerRegistration?
    private var moduleReference: DocumentReference?
    private var moduleListener: ListenerRegistration?

    init(moduleId: Identifier<Module>, user: User) {
        self.moduleId = moduleId
        self.user = user
        setUpConnectionToModule()
    }

    func setUpConnectionToModule() {
        if moduleId.val.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        userModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userModulePairs)
        currentModuleUsersQuery = userModulePairsReference?
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId.val)
        chatRoomsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
        userChatRoomModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
        currentUserChatRoomsQuery = userChatRoomModulePairsReference?
            .whereField(DatabaseConstant.UserChatRoomModulePair.userId, isEqualTo: userId.val)
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId.val)
        moduleReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.modules)
            .document(moduleId.val)
        loadUsers(onCompletion: { self.loadChatRooms(onCompletion: self.addListeners) })
    }

    private func loadUsers(onCompletion: (() -> Void)?) {
        currentModuleUsersQuery?.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                os_log("Error loading user module pairs: \(error?.localizedDescription ?? "No error")")
                return
            }
            let userIds: [Identifier<User>] = documents.compactMap {
                $0.data()[DatabaseConstant.UserModulePair.userId] as? String
            }
            .map({ Identifier<User>(val: $0) })
            FirebaseUserQuery.getUsers(withIds: userIds) { users in
                self.delegate?.insertAll(users: users)
                onCompletion?()
            }
        }
    }

    private func loadChatRooms(onCompletion: (() -> Void)?) {
        currentUserChatRoomsQuery?.getDocuments { querySnapshots, error in
            guard let documents = querySnapshots?.documents else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            let pairs = documents.compactMap { FirebaseUserChatRoomModulePairAdapter.convert(document: $0) }
            FirebaseChatRoomQuery.getChatRooms(pairs: pairs, user: self.user) { chatRooms in
                self.delegate?.insertAll(chatRooms: chatRooms)
            }
            onCompletion?()
        }
    }

    private func addListeners() {
        // This listens to new chatrooms that belongs to this user in the module
        userChatRoomModulePairsListener = currentUserChatRoomsQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserChatRoomModulePairDocumentChange(change)
            }
        }

        // This listens to new users in the module
        userModulePairsListener = currentModuleUsersQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
            }
        }

        // This listens to the module itself
        moduleListener = moduleReference?.addSnapshotListener { _, _ in
            FirebaseModuleQuery.getModule(moduleId: self.moduleId, user: self.user) { module in
                self.delegate?.update(module: module)
            }
        }
    }

    func save(chatRoom: ChatRoom,
              userPermissions: [UserPermissionPair],
              onCompletion: (() -> Void)?) {
        chatRoomsReference?
            .document(chatRoom.id.val)
            .setData(FirebaseChatRoomAdapter.convert(chatRoom: chatRoom)) { error in
                if let e = error {
                    os_log("Error sending chatRoom: \(e.localizedDescription)")
                    return
                }
                onCompletion?()
            }
        for userPermission in userPermissions {
            let pair = FirebaseUserChatRoomModulePair(
                userId: userPermission.userId,
                chatRoomId: chatRoom.id,
                moduleId: moduleId,
                permissions: userPermission.permissions)
            userChatRoomModulePairsReference?
                .addDocument(data: FirebaseUserChatRoomModulePairAdapter.convert(pair: pair)) { error in
                    if let e = error {
                        os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                        return
                    }
                }
        }
    }

    private func handleUserChatRoomModulePairDocumentChange(_ change: DocumentChange) {
        guard let pair = FirebaseUserChatRoomModulePairAdapter
                .convert(document: change.document) else {
            return
        }
        FirebaseChatRoomQuery.getChatRoom(pair: pair, user: self.user) { chatRoom in
            switch change.type {
            case .added:
                self.delegate?.insert(chatRoom: chatRoom)
            case .removed:
                self.delegate?.remove(chatRoom: chatRoom)
            default:
                break
            }
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let userModulePair = FirebaseUserModulePairFacade.convert(document: change.document) else {
            return
        }
        FirebaseUserQuery.getUser(withId: userModulePair.userId) { user in
            switch change.type {
            case .added:
                self.delegate?.insert(user: user)
            case .removed:
                self.delegate?.remove(user: user)
            default:
                break
            }
        }
    }
}
