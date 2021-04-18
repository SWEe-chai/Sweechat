import FirebaseFirestore
import os

/**
 A connection to the Firebase cloud service to handle `Module` related API calls.
 */
class FirebaseModuleFacade: ModuleFacade {
    weak var delegate: ModuleFacadeDelegate?

    private let db = Firestore.firestore()
    private let moduleId: Identifier<Module>
    private let user: User
    private var chatRoomsReference: CollectionReference?
    private var userChatRoomModulePairsReference: CollectionReference?
    private var currentUserChatRoomsQuery: Query?
    private var userChatRoomModulePairsListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentModuleUsersQuery: Query?
    private var userModulePairsListener: ListenerRegistration?
    private var moduleReference: DocumentReference?
    private var moduleListener: ListenerRegistration?

    private var userId: Identifier<User> {
        user.id
    }

    // MARK: Initialization

    /// Constructs a Firebase connection to listen to the module with the specified ID.
    init(moduleId: Identifier<Module>, user: User) {
        self.moduleId = moduleId
        self.user = user
        setUpConnectionToModule()
    }

    // MARK: ModuleFacade

    /// Saves the specified `ChatRoom` to Firebase and user permissions to Firebase,
    /// and executes the specified function on completion.
    /// - Parameters:
    ///   - chatRoom: The specified `ChatRoom`.
    ///   - userPermissions: The specified user permissions.
    ///   - onCompletion: The function to execute on completion.
    func save(chatRoom: ChatRoom, userPermissions: [UserChatRoomPermissionPair], onCompletion: (() -> Void)?) {
        saveChatRoom(chatRoom, onCompletion: onCompletion)
        saveUserPermissions(userPermissions, for: chatRoom)
    }

    // MARK: Private Helper Methods

    private func setUpConnectionToModule() {
        if moduleId.val.isEmpty {
            os_log("Error loading module: module ID is empty")
            return
        }

        setUpUserModulePairsReference()
        setUpModuleUsersQuery()
        setUpChatRoomsReference()
        setUpUserChatRoomModulePairsReference()
        setUpCurrentUserChatRoomsQuery()
        setUpModuleReference()

        loadUsers(onCompletion: { self.loadChatRooms(onCompletion: self.addListeners) })
    }

    private func setUpUserModulePairsReference() {
        userModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userModulePairs)
    }

    private func setUpModuleUsersQuery() {
        currentModuleUsersQuery = userModulePairsReference?
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId.val)
    }

    private func setUpChatRoomsReference() {
        chatRoomsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.chatRooms)
    }

    private func setUpUserChatRoomModulePairsReference() {
        userChatRoomModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userChatRoomModulePairs)
    }

    private func setUpCurrentUserChatRoomsQuery() {
        currentUserChatRoomsQuery = userChatRoomModulePairsReference?
            .whereField(DatabaseConstant.UserChatRoomModulePair.userId, isEqualTo: userId.val)
            .whereField(DatabaseConstant.UserModulePair.moduleId, isEqualTo: moduleId.val)
    }

    private func setUpModuleReference() {
        moduleReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.modules)
            .document(moduleId.val)
    }

    private func loadUsers(onCompletion: (() -> Void)?) {
        currentModuleUsersQuery?.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                os_log("Error loading user module pairs (\(error?.localizedDescription ?? ""))")
                return
            }

            let userIds: [Identifier<User>] = documents.compactMap {
                $0.data()[DatabaseConstant.UserModulePair.userId] as? String
            }
            .map({ Identifier<User>(val: $0) })

            FirebaseUserQuery.getUsers(withIds: userIds) { users in
                self.delegate?.insertAll(users: users)
            }

            onCompletion?()
        }
    }

    private func loadChatRooms(onCompletion: (() -> Void)?) {
        currentUserChatRoomsQuery?.getDocuments { querySnapshots, error in
            guard let documents = querySnapshots?.documents else {
                os_log("Error loading chatrooms (\(error?.localizedDescription ?? ""))")
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
        setUpUserChatRoomModulePairsListener() // Listen to new chatrooms belonging to this user in the module
        setUpUserModulePairsListener() // Listen to new users in the module
        setUpModuleListener() // Listen to changes in the module

    }

    private func setUpUserChatRoomModulePairsListener() {
        // This listens to new chatrooms that belongs to this user in the module
        userChatRoomModulePairsListener = currentUserChatRoomsQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates (\(error?.localizedDescription ?? ""))")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleUserChatRoomModulePairDocumentChange(change)
            }
        }
    }

    private func setUpUserModulePairsListener() {
        userModulePairsListener = currentModuleUsersQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates (\(error?.localizedDescription ?? ""))")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
            }
        }
    }

    private func setUpModuleListener() {
        moduleListener = moduleReference?.addSnapshotListener { _, _ in
            FirebaseModuleQuery.getModule(moduleId: self.moduleId, user: self.user) { module in
                self.delegate?.update(module: module)
            }
        }
    }

    private func saveChatRoom(_ chatRoom: ChatRoom, onCompletion: (() -> Void)?) {
        chatRoomsReference?
            .document(chatRoom.id.val)
            .setData(FirebaseChatRoomAdapter.convert(chatRoom: chatRoom)) { error in
                if let e = error {
                    os_log("Error sending chatRoom: \(e.localizedDescription)")
                    return
                }
                onCompletion?()
            }
    }

    private func saveUserPermissions(_ userPermissions: [UserChatRoomPermissionPair], for chatRoom: ChatRoom) {
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
        if let pair = FirebaseUserChatRoomModulePairAdapter.convert(document: change.document) {
            FirebaseChatRoomQuery.getChatRoom(pair: pair, user: self.user) { chatRoom in
                switch change.type {
                case .added:
                    self.delegate?.insert(chatRoom: chatRoom)
                case .removed:
                    self.delegate?.remove(chatRoom: chatRoom)
                default:
                    return
                }
            }
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        if let userModulePair = FirebaseUserModulePairAdapter.convert(document: change.document) {
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
}
