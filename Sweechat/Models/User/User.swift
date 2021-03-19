import Combine

class User: ObservableObject {
    @Published var id: String
    @Published var name: String
    @Published var profilePictureUrl: String?
    @Published var isLoggedIn: Bool = false
    private var userFacade: UserFacade

    static func createUser() -> User {
        User(id: "abc", name: "name")
    }

    private init(id: String, name: String, profilePictureUrl: String = "", email: String = "") {
        self.name = name
        self.id = id
        self.profilePictureUrl = profilePictureUrl
        self.userFacade = FirebaseUserFacade(userId: id)
        userFacade.delegate = self
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
        userFacade.loginAsUser(
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
