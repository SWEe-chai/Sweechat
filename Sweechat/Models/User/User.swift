import Combine

class User: ObservableObject {
    static let dummyUserId = ""
    static let dummyUserName = ""

    @Published var id: String
    @Published var name: String
    @Published var profilePictureUrl: String?
    var isLoggedIn: Bool = false {
        didSet {
            notifyIsLoggedInSubscribers(withValue: isLoggedIn)
        }
    }
    private var userFacade: UserFacade
    private var isLoggedInSubscribers: [((Bool) -> Void)] = []

    static func createDummyUser() -> User {
        User(details: UserRepresentation(id: dummyUserId, name: dummyUserName))
    }

    init(details: UserRepresentation) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.isLoggedIn = details.isLoggedIn
        self.userFacade = FirebaseUserFacade(userId: details.id)
        userFacade.delegate = self
    }

    func subscribeToIsLoggedIn(function: @escaping (Bool) -> Void) {
        isLoggedInSubscribers.append(function)
    }

    private func notifyIsLoggedInSubscribers(withValue isLoggedIn: Bool) {
        isLoggedInSubscribers.forEach { subscriber in
            subscriber(isLoggedIn)
        }
    }

}

// MARK: ALAuthDelegate
extension User: ALAuthDelegate {
    func signIn(withDetails details: ALLoginDetails) {
        userFacade.loginAndListenToUser(
            withDetails: UserRepresentation(
                id: details.id,
                name: details.name,
                profilePictureUrl: details.profilePictureUrl))
    }

    func signOut() {
        // TODO: Implement signout
    }
}

// MARK: UserFacadeDelegate
extension User: UserFacadeDelegate {
    func updateUserData(withDetails details: UserRepresentation) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.isLoggedIn = details.isLoggedIn
    }
}
