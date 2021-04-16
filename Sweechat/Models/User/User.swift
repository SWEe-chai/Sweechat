import Combine
import Foundation

class User: ObservableObject {
    static let unvailableUserId: Identifier<User> = ""
    static let unvailableUserName = "Unavailable User"

    @Published var id: Identifier<User>
    @Published var name: String
    @Published var profilePictureUrl: String?

    private let isLoggedInSubscribers: [((Bool) -> Void)] = []
    private let groupCryptographyProvider: GroupCryptographyProvider
    private var userFacade: UserFacade?

    static func createUnavailableInstance() -> User {
        User(id: unvailableUserId, name: unvailableUserName)
    }

    // MARK: Initialization

    init(id: Identifier<User>) {
        self.id = id
        self.name = ""
        self.profilePictureUrl = ""
        self.groupCryptographyProvider = SignalProtocol(userId: id.val)
    }

    init(id: Identifier<User>, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.groupCryptographyProvider = SignalProtocol(userId: id.val)
    }

    // MARK: Facade Connection

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

    func getPublicKeyBundleData() -> Data? {
        try? groupCryptographyProvider.getPublicServerKeyBundleData()
    }

    // MARK: Subscriptions

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
    }

    func subscribeToProfilePicture(function: @escaping (String?) -> Void) -> AnyCancellable {
        $profilePictureUrl.sink(receiveValue: function)
    }
}

// MARK: Equatable
extension User: Equatable, Comparable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: User, rhs: User) -> Bool {
        lhs.id.val < rhs.id.val
    }
}

// MARK: UserFacadeDelegate
extension User: UserFacadeDelegate {
    func update(user: User) {
        self.id = user.id
        self.name = user.name
        self.profilePictureUrl = user.profilePictureUrl
    }
}
