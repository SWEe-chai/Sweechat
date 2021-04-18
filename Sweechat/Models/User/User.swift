import Combine
import Foundation

/**
 Represents a user of the application.
 */
class User: ObservableObject {
    static let unvailableUserId: Identifier<User> = ""
    static let unvailableUserName = "Unavailable User"

    @Published var id: Identifier<User>
    @Published var name: String
    @Published var profilePictureUrl: String?

    private let isLoggedInSubscribers: [((Bool) -> Void)] = []
    private let groupCryptographyProvider: GroupCryptographyProvider
    private var userFacade: UserFacade?

    /// Creates an instance of an unavailable `User`.
    /// This method should be called when there is an error retrieving user information from the server.
    /// - Returns: An instance of an unavailable `User`.
    static func createUnavailableInstance() -> User {
        User(id: unvailableUserId, name: unvailableUserName)
    }

    // MARK: Initialization

    /// Constructs a `User` with the specified ID.
    init(id: Identifier<User>) {
        self.id = id
        self.name = ""
        self.profilePictureUrl = ""
        self.groupCryptographyProvider = SignalProtocol(userId: id.val)
    }

    /// Constructs a `User` with the specified ID and name.
    init(id: Identifier<User>, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.groupCryptographyProvider = SignalProtocol(userId: id.val)
    }

    // MARK: Facade Connection

    /// Sets up a connection to the server to listen to updates to this `User`.
    func setUserConnection() {
        self.userFacade = FirebaseUserFacade(userId: id)
        userFacade?.delegate = self
        userFacade?.loginAndListenToUser(
            User(
                id: id,
                name: name,
                profilePictureUrl: profilePictureUrl
            )
        )
    }

    // MARK: Cryptography Public Key Bundle

    /// Gets this `User`'s public key bundle data to upload to the server.
    /// - Returns: This `User`'s public key bundle data, or `nil` if the data cannot be retrieved.
    func getPublicKeyBundleData() -> Data? {
        try? groupCryptographyProvider.getPublicServerKeyBundleData()
    }

    // MARK: Subscriptions

    /// Subscribes to the this `User`'s name by executing the specified function on change to the name.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the name.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    /// Subscribes to the this `User`'s profile picture by executing the specified function
    /// on change to the profile picture.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the profile picture.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToProfilePicture(function: @escaping (String?) -> Void) -> AnyCancellable {
        $profilePictureUrl.sink(receiveValue: function)
    }
}

// MARK: Equatable
extension User: Equatable, Comparable {
    /// Whether two `User`s are equal.
    /// - Parameters:
    ///   - lhs: The first `User`.
    ///   - rhs: The second `User`.
    /// - Returns: `true` if the two `User`s are equal.
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    /// Whether the first `User` is less than the second.
    /// - Parameters:
    ///   - lhs: The first `User`.
    ///   - rhs: The second `User`.
    /// - Returns: `true` if the first `User` is less than the second.
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.id.val < rhs.id.val
    }
}

// MARK: UserFacadeDelegate
extension User: UserFacadeDelegate {
    /// Updates this`User` with information from the specified `User`.
    /// - Parameters:
    ///   - user: The specified `User`.
    func update(user: User) {
        self.id = user.id
        self.name = user.name
        self.profilePictureUrl = user.profilePictureUrl
    }
}
