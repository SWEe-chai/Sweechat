import Combine

class User: ObservableObject {
    static let dummyUserId = ""
    static let dummyUserName = ""
    static let deletedUserName = "Deleted User"

    @Published var id: String
    @Published var name: String
    @Published var profilePictureUrl: String?
    @Published var isLoggedIn: Bool = false
    private var userFacade: UserFacade

    static func createDummyUser() -> User {
        User(details: UserRepresentation(id: dummyUserId, name: dummyUserName))
    }
    static func createDeletedUser() -> User {
        User(details: UserRepresentation(id: dummyUserId, name: deletedUserName))
    }

    init(details: UserRepresentation) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.isLoggedIn = details.isLoggedIn
        self.userFacade = FirebaseUserFacade(userId: details.id)
        userFacade.delegate = self
    }

    func subscribeToSignedIn(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $isLoggedIn.sink(receiveValue: function)
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
