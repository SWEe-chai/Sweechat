//
//  FirebaseChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseChatRoomFacade: ChatRoomFacade {
    weak var delegate: ChatRoomFacadeDelegate?
    private var chatRoomId: Identifier<ChatRoom>
    private var user: User

    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    private var publicKeyBundlesReference: CollectionReference?
    private var chatRoomReference: DocumentReference?
    private var chatRoomListener: ListenerRegistration?
    private var messagesReference: CollectionReference?
    private var filteredMessagesReference: Query?
    private var messagesUpdateListener: ListenerRegistration?
    private var messagesInsertListener: ListenerRegistration?
    private var userChatRoomModulePairsFilteredQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?
    private var oldestMessageDocument: QueryDocumentSnapshot?

    init(chatRoomId: Identifier<ChatRoom>, user: User, delegate: ChatRoomFacadeDelegate) {
        self.chatRoomId = chatRoomId
        self.user = user
        self.delegate = delegate
        setUpConnectionToChatRoom()
    }

    func setUpConnectionToChatRoom() {
        if chatRoomId.val.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        publicKeyBundlesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.publicKeyBundles)
        userChatRoomModulePairsFilteredQuery = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId.val)
        messagesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId.val)
            .collection(DatabaseConstant.Collection.messages)
        filteredMessagesReference = messagesReference?
            .whereField(DatabaseConstant.Message.receiverId, isEqualTo: ChatRoom.allUsersId)
        chatRoomReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId.val)
        loadMembers(onCompletion: {
            self.loadKeyExchangeMessages(onCompletion: {
                self.loadMessages(onCompletion: self.addListeners)
            })
        })
    }

    private func loadMembers(onCompletion: (() -> Void)?) {
        FirebaseUserChatRoomModulePairQuery
            .getUserChatRoomModulePairs(inChatRoomId: chatRoomId) { pairs in
                let userIds: [String] = pairs.map { $0.userId }
                FirebaseUserQuery.getUsers(withIds: userIds) { users in
                    self.delegate?.insertAll(members: users)
                    onCompletion?()
                }
            }
    }

    private func loadKeyExchangeMessages(onCompletion: (() -> Void)?) {
        messagesReference?
            .whereField(DatabaseConstant.Message.type, isEqualTo: MessageType.keyExchange.rawValue)
            .whereField(DatabaseConstant.Message.receiverId, isEqualTo: user.id)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let delegate = self.delegate else {
                    os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageFacade.convert(document: $0)
                })
                if delegate.handleKeyExchangeMessages(keyExchangeMessages: messages) {
                    onCompletion?()
                } else {
                    os_log("Key exchange failed, waiting for new keys")
                }
            }
    }

    private func loadMessages(onCompletion: (() -> Void)?) {
        filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .limit(toLast: 20)
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                    onCompletion?()
                    return
                }
                self.oldestMessageDocument = snapshot.documents.first
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageFacade.convert(document: $0)
                })
                self.delegate?.insertAll(messages: messages)
                onCompletion?()
            }
    }

    private func addListeners() {
        chatRoomListener = chatRoomReference?.addSnapshotListener { _, _ in
            FirebaseChatRoomQuery.getChatRoom(chatRoomId: self.chatRoomId, user: self.user) { chatRoom in
                self.delegate?.update(chatRoom: chatRoom)
            }
        }

        messagesUpdateListener = filteredMessagesReference?
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error listening for all messages: \(error?.localizedDescription ?? "No error")")
                    return
                }
                snapshot.documentChanges
                    .filter { $0.type != .added }
                    .forEach { self.handleMessageDocumentChange($0) }
            }

        messagesInsertListener = filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .limit(toLast: 1)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error listening for new messages: \(error?.localizedDescription ?? "No error")")
                    return
                }
                snapshot.documentChanges
                    .filter { $0.type == .added }
                    .forEach { self.handleMessageDocumentChange($0) }
            }

        userChatRoomModulePairsListener = userChatRoomModulePairsFilteredQuery?
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                snapshot.documentChanges.forEach { change in
                    self.handleUserModulePairDocumentChange(change)
                }
            }
    }

    func loadNextBlock(_ numberOfMessages: Int, onCompletion: @escaping ([Message]) -> Void) {
        guard let oldestMessageDocument = self.oldestMessageDocument else {
            os_log("Trying to load next block but not available")
            onCompletion([])
            return
        }
        filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .end(beforeDocument: oldestMessageDocument)
            .limit(toLast: numberOfMessages)
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let oldestMessageDocument = snapshot.documents.first else {
                    os_log("No more messages: \(error?.localizedDescription ?? "No error")")
                    onCompletion([])
                    return
                }
                self.oldestMessageDocument = oldestMessageDocument
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageFacade.convert(document: $0)
                })
                onCompletion(messages)
            }
    }

    func loadMessage(withId id: String, onCompletion: @escaping (Message?) -> Void) {
        messagesReference?
            .document(id)
            .getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                    onCompletion(nil)
                    return
                }
                onCompletion(FirebaseMessageFacade.convert(document: snapshot))
            }
    }

    func loadUntil(_ time: Date, onCompletion: @escaping ([Message]) -> Void) {
        filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .whereField(DatabaseConstant.Message.creationTime, isGreaterThan: time)
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let oldestMessageDocument = snapshot.documents.first else {
                    os_log("Error loading messages: \(error?.localizedDescription ?? "No error")")
                    onCompletion([])
                    return
                }
                self.oldestMessageDocument = oldestMessageDocument
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageFacade.convert(document: $0)
                })
                onCompletion(messages)
            }
    }

    func save(_ message: Message) {
        messagesReference?
            .document(message.id.val)
            .setData(FirebaseMessageFacade.convert(message: message)) { error in
                if let e = error {
                    os_log("Error sending message: \(e.localizedDescription)")
                    return
                }
            }
    }

    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?) {
        storage.child(fileName).putData(data, metadata: nil) { _, err in
            guard err == nil else {
                os_log("failed to upload data to firebase")
                return
            }

            self.storage.child(fileName).downloadURL { url, _ in
                guard let url = url else {
                    os_log("failed to get download url")
                    return
                }

                onCompletion?(url)
            }
        }
    }

    func loadPublicKeyBundlesFromStorage(of users: [User], onCompletion: (([String: Data]) -> Void)?) {
        self.publicKeyBundlesReference?
            // TODO: Chunk this users array so that we can ensure that it's less than 10
            .whereField(DatabaseConstant.PublicKeyBundle.userId, in: users.map({ $0.id }))
            .getDocuments { querySnapshot, err in
                guard err == nil,
                      let documents = querySnapshot?.documents else {
                    os_log("Error fetching public key bundles")
                    return
                }

                var publicKeyBundles: [String: Data] = [:]

                documents.forEach({
                    let data = $0.data()
                    if let userId = data[DatabaseConstant.PublicKeyBundle.userId] as? String,
                       let bundleData = data[DatabaseConstant.PublicKeyBundle.bundleData] as? Data {
                        publicKeyBundles[userId] = bundleData
                    }
                })

                onCompletion?(publicKeyBundles)
            }
    }

    func delete(_ message: Message) {
        self.messagesReference?
            .document(message.id.val)
            .delete { err in
                if err != nil {
                    os_log("Error deleting message")
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
        case .modified:
            self.delegate?.update(message: message)
        case .removed:
            self.delegate?.remove(message: message)
        default:
            break
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let pair = FirebaseUserChatRoomModulePairFacade.convert(document: change.document) else {
            return
        }
        FirebaseUserQuery.getUser(withId: pair.userId) { user in
            switch change.type {
            case .added:
                self.delegate?.insert(member: user)
            case .removed:
                self.delegate?.remove(member: user)
            default:
                break
            }
        }
    }

    static func convert(document: DocumentSnapshot,
                        user: User,
                        withPermissions permissions: ChatRoomPermissionBitmask) -> ChatRoom? {
        if !document.exists {
            os_log("Error: Cannot convert chat room, chat room document does not exist")
            return nil
        }
        let data = document.data()
        guard let idString = data?[DatabaseConstant.ChatRoom.id] as? String,
              let name = data?[DatabaseConstant.ChatRoom.name] as? String,
              let ownerId = data?[DatabaseConstant.ChatRoom.ownerId] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String,
              let type = ChatRoomType(rawValue: data?[DatabaseConstant.ChatRoom.type] as? String ?? "") else {
            os_log("Error converting data for ChatRoom, data: %s", String(describing: data))
            return nil
        }

        let id = Identifier<ChatRoom>(val: idString)
        switch type {
        case .groupChat:
            return GroupChatRoom(
                id: id,
                name: name,
                ownerId: ownerId,
                currentUser: user,
                currentUserPermission: permissions,
                profilePictureUrl: profilePictureUrl)
        case .privateChat:
            return PrivateChatRoom(
                id: id,
                ownerId: ownerId,
                currentUser: user)
        case .forum:
            return ForumChatRoom(
                id: id,
                name: name,
                ownerId: ownerId,
                currentUser: user,
                currentUserPermission: permissions,
                profilePictureUrl: profilePictureUrl)
        case .thread:
            return ThreadChatRoom(
                id: id,
                ownerId: ownerId,
                currentUser: user)
        }
    }

    static func convert(chatRoom: ChatRoom) -> [String: Any] {
        var document: [String: Any] = [
            DatabaseConstant.ChatRoom.id: chatRoom.id.val,
            DatabaseConstant.ChatRoom.name: chatRoom.name,
            DatabaseConstant.ChatRoom.ownerId: chatRoom.ownerId,
            DatabaseConstant.ChatRoom.profilePictureUrl: chatRoom.profilePictureUrl ?? ""
        ]
        switch chatRoom {
        case chatRoom as PrivateChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.privateChat.rawValue
        case chatRoom as GroupChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.groupChat.rawValue
        case chatRoom as ForumChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.forum.rawValue
        case chatRoom as ThreadChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.thread.rawValue
        default:
            os_log("Firebase ChatRoom Facade: Trying to convert abstract class ChatRoom")
            fatalError("ChatRoom must be either a group chat or private chat")
        }
        return document
    }
}
