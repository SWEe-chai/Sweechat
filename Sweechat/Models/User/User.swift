import Combine

class User: ObservableObject {
    @Published var id: String
    @Published var name: String?
    @Published var profilePictureUrl: String?
    @Published var signedIn: Bool = false
    private var userFacade: UserFacade

    static func createUser() -> User {
        User(id: "abc", name: "name")
    }

    private init(id: String, name: String, profilePictureUrl: String = "", email: String = "") {
        self.name = name
        self.id = id
        self.profilePictureUrl = photoUrl
        self.userFacade = FirebaseUserFacade()
        userFacade.delegate = self
    }
    
    init(details: UserDetails) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.isLoggedIn = details.isLoggedIn
    }

    func subscribeToSignedIn(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $signedIn.sink(receiveValue: function)
    }
}

// MARK: ALAuthDelegate
extension User: ALAuthDelegate {
    func signIn(withDetails details: ALLoginDetails) {
        userFacade.loginAsUser(
            withDetails: UserDetails(
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
    func updateUserData(withDetails details: UserDetails) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.signedIn = details.isLoggedIn
    }
}
