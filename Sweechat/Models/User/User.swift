import Combine
import Foundation

class User: ObservableObject {
    static let unvailableUserId: Identifier<User> = ""
    static let unvailableUserName = "Unavailable User"

    @Published var id: Identifier<User>
    @Published var name: String
    @Published var profilePictureUrl: String?
    private var userFacade: UserFacade?
    private var isLoggedInSubscribers: [((Bool) -> Void)] = []
    private var groupCryptographyProvider: GroupCryptographyProvider

    static func createUnavailableUser() -> User {
        User(id: unvailableUserId, name: unvailableUserName)
    }

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

    func getPublicKeyBundleData() -> Data? {
        try? groupCryptographyProvider.getPublicServerKeyBundleData()
    }

//    func initiateListeningToUser() {
//        let user = User(
//            id: id,
//            name: name,
//            profilePictureUrl: profilePictureUrl
//        )
//        
//
//        userFacade.loginAndListenToUser(
//        )
//    }

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
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
