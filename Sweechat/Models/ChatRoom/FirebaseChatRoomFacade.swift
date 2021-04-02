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
    private var chatRoomId: String
    private var user: User

    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    private var chatRoomReference: DocumentReference?
    private var chatRoomListener: ListenerRegistration?
    private var messagesReference: CollectionReference?
    private var messagesListener: ListenerRegistration?
    private var userChatRoomModulePairsFilteredQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?

    init(chatRoomId: String, user: User) {
        self.chatRoomId = chatRoomId
        self.user = user
        setUpConnectionToChatRoom()
    }

    func setUpConnectionToChatRoom() {
        if chatRoomId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        userChatRoomModulePairsFilteredQuery = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
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
        loadMembers(onCompletion: { self.loadMessages(onCompletion: self.addListeners) })
    }

    private func loadMembers(onCompletion: (() -> Void)?) {
        userChatRoomModulePairsFilteredQuery?.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error loading user module pairs: \(error?.localizedDescription ?? "No error")")
                return
            }
            let userIds: [String] = snapshot.documents.compactMap {
                $0.data()[DatabaseConstant.UserModulePair.userId] as? String
            }
            FirebaseUserQuery.getUsers(withIds: userIds) { users in
                self.delegate?.insertAll(members: users)
                onCompletion?()
            }
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
        chatRoomListener = chatRoomReference?.addSnapshotListener { documentChange, error in
            guard let change = documentChange else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            // TODO: This is a pain point, we need to get
            FirebaseUserChatRoomModulePairFacade.getUserChatRoomModulePair(
                chatRoomId: self.chatRoomId,
                userId: self.user.id) { pair in
                guard let pair = pair,
                      let chatRoom = FirebaseChatRoomFacade
                        .convert(document: change,
                                 user: self.user,
                                 withPermissions: pair.permissions) else {
                    return
                }
                self.delegate?.update(chatRoom: chatRoom)
            }
        }

        messagesListener = messagesReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleMessageDocumentChange(change)
            }
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

    func save(_ message: Message) {
        messagesReference?.addDocument(data: FirebaseMessageFacade.convert(message: message)) { error in
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
        guard let id = data?[DatabaseConstant.ChatRoom.id] as? String,
              let name = data?[DatabaseConstant.ChatRoom.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String,
              let type = ChatRoomType(rawValue: data?[DatabaseConstant.ChatRoom.type] as? String ?? "") else {
            os_log("Error converting data for chat room")
            return nil
        }

        switch type {
        case .groupChat:
            return GroupChatRoom(
                id: id,
                name: name,
                currentUser: user,
                currentUserPermission: permissions,
                profilePictureUrl: profilePictureUrl)
        case .privateChat:
            return PrivateChatRoom(
                id: id,
                currentUser: user)
        case .forum:
            return ForumChatRoom(
                id: id,
                name: name,
                currentUser: user,
                currentUserPermission: permissions,
                profilePictureUrl: profilePictureUrl)
        }
    }

    static func convert(chatRoom: ChatRoom) -> [String: Any] {
        var document = [
            DatabaseConstant.ChatRoom.id: chatRoom.id,
            DatabaseConstant.ChatRoom.name: chatRoom.name,
            DatabaseConstant.ChatRoom.profilePictureUrl: chatRoom.profilePictureUrl ?? ""
        ]
        switch chatRoom {
        case chatRoom as PrivateChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.privateChat.rawValue
        case chatRoom as GroupChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.groupChat.rawValue
        case chatRoom as ForumChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.forum.rawValue
        default:
            os_log("Firebase ChatRoom Facade: Trying to convert abstract class ChatRoom")
            fatalError("ChatRoom must be either a group chat or private chat")
        }
        return document
    }
}
