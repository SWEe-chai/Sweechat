import FirebaseFirestore
import FirebaseStorage
import os

/**
 A connection to the Firebase cloud service to handle `ChatRoom` related API calls.
 */
class FirebaseChatRoomFacade: ChatRoomFacade {
    weak var delegate: ChatRoomFacadeDelegate?

    private let user: User
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private let messageBlockSize: Int = 6
    private var chatRoomId: Identifier<ChatRoom>
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

    // MARK: Initialization

    /// Constructs a `ChatRoom` with the specified information.
    init(chatRoomId: Identifier<ChatRoom>, user: User, delegate: ChatRoomFacadeDelegate) {
        self.chatRoomId = chatRoomId
        self.user = user
        self.delegate = delegate
        setUpConnectionToChatRoom()
    }

    // MARK: ChatRoomFacade

    /// Saves the specified `Message` to Firebase.
    /// - Parameters:
    ///   - message: The specified `Message`.
    func save(_ message: Message) {
        messagesReference?
            .document(message.id.val)
            .setData(FirebaseMessageAdapter.convert(message: message)) { error in
                if let e = error {
                    os_log("Error sending message: \(e.localizedDescription)")
                    return
                }
            }
    }

    /// Uploads the specified file data to Firebase and executes the specified function on completion.
    /// - Parameters:
    ///   - data: The specified file data.
    ///   - fileName: The specified file name.
    ///   - onCompletion: The function to execute on completion.
    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?) {
        storage.child(fileName).putData(data, metadata: nil) { _, error in
            guard error == nil else {
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

    /// Loads the next block of `Message`s from Firebase and runs the specified function on completion.
    /// - Parameters:
    ///   - onCompletion: The specified function to run on completion.
    func loadNextBlockOfMessages(onCompletion: @escaping ([Message]) -> Void) {
        guard let oldestMessageDocument = self.oldestMessageDocument else {
            os_log("Trying to load next block but not available")
            onCompletion([])
            return
        }
        filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .end(beforeDocument: oldestMessageDocument)
            .limit(toLast: messageBlockSize)
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let oldestMessageDocument = snapshot.documents.first else {
                    os_log("No more messages (\(error?.localizedDescription ?? ""))")
                    onCompletion([])
                    return
                }
                self.compareAndSetOldestMessageDocument(oldestMessageDocument)
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageAdapter.convert(document: $0)
                })
                onCompletion(messages)
            }
    }

    /// Loads the `Message` with the specified ID from Firebase and executes the specified function on completion.
    /// - Parameters:
    ///   - id: The specified ID.
    ///   - onCompletion: The specified function to execute on completion.
    func loadMessage(withId id: String, onCompletion: @escaping (Message?) -> Void) {
        messagesReference?
            .document(id)
            .getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error loading message (\(error?.localizedDescription ?? ""))")
                    onCompletion(nil)
                    return
                }
                onCompletion(FirebaseMessageAdapter.convert(document: snapshot))
            }
    }

    /// Loads the 
    func loadMessagesUntil(_ time: Date, onCompletion: @escaping ([Message]) -> Void) {
        let timestamp = Timestamp(date: time)
        filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .start(at: [timestamp])
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let oldestMessageDocument = snapshot.documents.first else {
                    os_log("Error loading messages (\(error?.localizedDescription ?? ""))")
                    onCompletion([])
                    return
                }
                self.compareAndSetOldestMessageDocument(oldestMessageDocument)
                let messages = snapshot.documents.compactMap({
                    FirebaseMessageAdapter.convert(document: $0)
                })
                onCompletion(messages)
            }
    }

    func loadPublicKeyBundlesFromStorage(of users: [User], onCompletion: (([String: Data]) -> Void)?) {
        for chunk in users.chunked(into: FirebaseUtils.queryChunkSize) {
            self.publicKeyBundlesReference?
                .whereField(DatabaseConstant.PublicKeyBundle.userId, in: chunk.map({ $0.id.val }))
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
    }

    func delete(_ message: Message) {
        self.messagesReference?
            .document(message.id.val)
            .delete { error in
                if error != nil {
                    os_log("Error deleting message")
                }
            }
    }

    // MARK: Private Helper Methods

    private func setUpConnectionToChatRoom() {
        if chatRoomId.val.isEmpty {
            os_log("Error loading chatroom: Chat Room ID is empty")
            return
        }

        setUpPublicKeyBundlesReference()
        setUpUserChatRoomModulePairsFilteredQuery()
        setUpMessagesReference()
        setUpFilteredMessagesReference()
        setUpChatRoomReference()

        loadMembers(onCompletion: {
            self.loadKeyExchangeMessages(onCompletion: {
                self.loadMessages(onCompletion: self.addListeners)
            })
        })
    }

    private func setUpPublicKeyBundlesReference() {
        publicKeyBundlesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.publicKeyBundles)
    }

    private func setUpUserChatRoomModulePairsFilteredQuery() {
        userChatRoomModulePairsFilteredQuery = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
            .whereField(DatabaseConstant.UserChatRoomModulePair.chatRoomId, isEqualTo: chatRoomId.val)
    }

    private func setUpMessagesReference() {
        messagesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId.val)
            .collection(DatabaseConstant.Collection.messages)
    }

    private func setUpFilteredMessagesReference() {
        filteredMessagesReference = messagesReference?
            .whereField(DatabaseConstant.Message.receiverId, isEqualTo: ChatRoom.allUsersId.val)
    }

    private func setUpChatRoomReference() {
        chatRoomReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
            .document(chatRoomId.val)
    }

    private func loadMembers(onCompletion: (() -> Void)?) {
        FirebaseUserChatRoomModulePairQuery.getUserChatRoomModulePairs(chatRoomId: chatRoomId) { pairs in
            FirebaseUserQuery.getUsers(withIds: pairs.map { $0.userId }) { users in
                self.delegate?.insertAll(members: users)
                onCompletion?()
            }
        }
    }

    private func loadKeyExchangeMessages(onCompletion: (() -> Void)?) {
        messagesReference?
            .whereField(DatabaseConstant.Message.type, isEqualTo: MessageType.keyExchange.rawValue)
            .whereField(DatabaseConstant.Message.receiverId, isEqualTo: user.id.val)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      let delegate = self.delegate else {
                    os_log("Error loading messages (\(error?.localizedDescription ?? ""))")
                    return
                }

                let messages = snapshot.documents.compactMap({ FirebaseMessageAdapter.convert(document: $0) })

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
            .limit(toLast: messageBlockSize)
            .getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error loading messages (\(error?.localizedDescription ?? ""))")
                    onCompletion?()
                    return
                }

                self.oldestMessageDocument = snapshot.documents.first

                let messages = snapshot.documents.compactMap({
                    FirebaseMessageAdapter.convert(document: $0)
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

        setUpMessagesUpdateListener()
        setUpMessagesInsertListener()
        setUpUserChatRoomModulePairsListener()
    }

    private func setUpMessagesUpdateListener() {
        messagesUpdateListener = filteredMessagesReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for all messages (\(error?.localizedDescription ?? ""))")
                return
            }

            snapshot.documentChanges
                .filter { $0.type != .added }
                .forEach { self.handleMessageDocumentChange($0) }
        }
    }

    private func setUpMessagesInsertListener() {
        messagesInsertListener = filteredMessagesReference?
            .order(by: DatabaseConstant.Message.creationTime)
            .limit(toLast: 1)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error listening for new messages (\(error?.localizedDescription ?? ""))")
                    return
                }
                snapshot.documentChanges
                    .filter { $0.type == .added }
                    .forEach { self.handleMessageDocumentChange($0) }
            }
    }

    private func setUpUserChatRoomModulePairsListener() {
        userChatRoomModulePairsListener = userChatRoomModulePairsFilteredQuery?
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    os_log("Error listening for channel updates (\(error?.localizedDescription ?? ""))")
                    return
                }
                snapshot.documentChanges.forEach { change in
                    self.handleUserModulePairDocumentChange(change)
                }
            }
    }

    private func compareAndSetOldestMessageDocument(_ oldestMessageDocument: QueryDocumentSnapshot) {
        if let previousTime = self.oldestMessageDocument?[DatabaseConstant.Message.creationTime] as? Timestamp,
           let newTime = oldestMessageDocument[DatabaseConstant.Message.creationTime] as? Timestamp,
           newTime.dateValue() < previousTime.dateValue() {
            self.oldestMessageDocument = oldestMessageDocument
        }
    }

    private func handleMessageDocumentChange(_ change: DocumentChange) {
        guard let message = FirebaseMessageAdapter.convert(document: change.document) else {
            return
        }

        guard !message.senderId.val.isEmpty else {
            os_log("Error reading message: Message sender ID is empty")
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
            return
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let pair = FirebaseUserChatRoomModulePairAdapter.convert(document: change.document) else {
            return
        }

        FirebaseUserQuery.getUser(withId: pair.userId) { user in
            switch change.type {
            case .added:
                self.delegate?.insert(member: user)
            case .removed:
                self.delegate?.remove(member: user)
            default:
                return
            }
        }
    }
}
