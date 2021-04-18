
import Combine
import Foundation

/**
 Represents a module in the application.
 */
class Module: ObservableObject {
    static let unavailableModuleId = Identifier<Module>("")
    static let unavailableModuleName = "Unavailable Module"

    let currentUser: User
    let currentUserPermission: ModulePermissionBitmask
    var id: Identifier<Module>
    var profilePictureUrl: String?
    var userIdsToUsers: [Identifier<User>: User] = [:]

    @Published var name: String
    @Published var chatRooms: [ChatRoom]
    @Published var members: [User] {
        didSet {
            for user in members {
                self.userIdsToUsers[user.id] = user
            }
        }
    }

    private var moduleFacade: ModuleFacade?

    /// Creates an instance of an unavailable `Module`.
    /// This method should be called when there is an error retrieving module information from the server.
    /// - Returns: An instance of an unavailable `Module`.
    static func createUnavailableInstance() -> Module {
        Module(
            id: unavailableModuleId,
            name: unavailableModuleName,
            currentUser: User.createUnavailableInstance(),
            currentUserPermission: ModulePermissionBitmask()
        )
    }

    // MARK: Initialization

    /// Constructs a `Module` for use in facade translation with the cloud service provider.
    init(id: Identifier<Module>,
         name: String,
         currentUser: User,
         currentUserPermission: ModulePermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.currentUser = currentUser
        self.currentUserPermission = currentUserPermission
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = []
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    /// Constructs a `Module` to display on the screen.
    init(name: String,
         users: [User],
         currentUser: User,
         currentUserPermission: ModulePermissionBitmask,
         profilePictureUrl: String? = nil) {
        self.id = Identifier<Module>(val: UUID().uuidString)
        self.name = name
        self.currentUser = currentUser
        self.currentUserPermission = currentUserPermission
        self.profilePictureUrl = profilePictureUrl
        self.chatRooms = []
        self.members = users
        self.moduleFacade = nil
        self.userIdsToUsers = [:]
    }

    // MARK: Facade Connection

    /// Sets up a connection to the server to listen to updates to this `Module`.
    func setModuleConnection() {
        self.moduleFacade = FirebaseModuleFacade(
            moduleId: self.id,
            user: currentUser)
        self.moduleFacade?.delegate = self
    }

    /// Stores the specified `ChatRoom` and associated user permissions on the server,
    /// and executes the specified function on completion.
    /// - Parameters:
    ///   - chatRoom: The specified `ChatRoom`.
    ///   - userPermissions: The specified user permissions.
    ///   - onCompletion: The function to execute on completion.
    func store(chatRoom: ChatRoom, userPermissions: [UserPermissionPair], onCompletion: (() -> Void)? = nil) {
        assert(chatRoom.members.count == userPermissions.count)
        self.moduleFacade?.save(
            chatRoom: chatRoom,
            userPermissions: userPermissions,
            onCompletion: onCompletion)
    }

    // MARK: Subscriptions

    /// Subscribes to the this `Module`'s name by executing the specified function on change to the name.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the name.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    /// Subscribes to the this `Module`'s chatrooms by executing the specified function on change to the chatrooms.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the chatrooms.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToChatrooms(function: @escaping ([ChatRoom]) -> Void) -> AnyCancellable {
        $chatRooms.sink(receiveValue: function)
    }

    /// Subscribes to the this `Module`'s members by executing the specified function on change to the members.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the members.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToMembers(function: @escaping ([User]) -> Void) -> AnyCancellable {
        $members.sink(receiveValue: function)
    }
}

// MARK: ModuleFacadeDelegate
extension Module: ModuleFacadeDelegate {
    /// Inserts the specified `ChatRoom` into this `Module`.
    /// - Parameters:
    ///   - chatRoom: The specified `ChatRoom`.
    func insert(chatRoom: ChatRoom) {
        if !self.chatRooms.contains(chatRoom),
              chatRoom as? ThreadChatRoom == nil {
            chatRoom.setChatRoomConnection()
            self.chatRooms.append(chatRoom)
        }
    }

    /// Inserts the specified `ChatRoom`s into this `Module`.
    /// - Parameters:
    ///   - chatRooms: The specified `ChatRoom`s.
    func insertAll(chatRooms: [ChatRoom]) {
        let newChatRooms = chatRooms.filter({ $0 as? ThreadChatRoom == nil }).filter({ !chatRooms.contains($0) })
        newChatRooms.forEach { $0.setChatRoomConnection() }
        self.chatRooms.append(contentsOf: newChatRooms)
    }

    /// Removes the specified `ChatRoom` from this `Module`.
    /// - Parameters:
    ///   - chatRoom: The specified `ChatRoom`.
    func remove(chatRoom: ChatRoom) {
        if let index = chatRooms.firstIndex(of: chatRoom) {
            self.chatRooms.remove(at: index)
        }
    }

    /// Inserts the specified `User` into this `Module`.
    /// - Parameters:
    ///   - user: The specified `User`.
    func insert(user: User) {
        if !self.members.contains(user) {
            user.setUserConnection()
            self.members.append(user)
        }
    }

    /// Removes the specified `User` from this `Module`.
    /// - Parameters:
    ///   - user: The specified `User`.
    func remove(user: User) {
        if let index = members.firstIndex(of: user) {
            self.members.remove(at: index)
        }
    }

    /// Inserts the specified `User`s into this `Module`.
    /// - Parameters:
    ///   - users: The specified `User`s.
    func insertAll(users: [User]) {
        for user in users {
            self.userIdsToUsers[user.id] = user
        }
    }

    /// Updates this `Module` with information from the specified `Module`.
    /// - Parameters:
    ///   - module: The specified `Module`.
    func update(module: Module) {
        self.name = module.name
        self.profilePictureUrl = module.profilePictureUrl
    }
}

extension Module: Equatable {
    /// Whether two `Module`s are equal.
    /// - Parameters:
    ///   - lhs: The first `Module`.
    ///   - rhs: The second `Module`.
    /// - Returns: `true` if the two `Module`s are equal.
    static func == (lhs: Module, rhs: Module) -> Bool {
        lhs.id == rhs.id
    }
}
