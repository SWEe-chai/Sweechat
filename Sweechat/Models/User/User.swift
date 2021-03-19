import Combine

class User: ObservableObject {
    @Published var id: String
    @Published var username: String?
    @Published var email: String
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var profilePictureURL: String?
    @Published var signedIn: Bool = false
    private var userFacade: UserFacade

    static func createUser() -> User {
        User(id: "abc", firstName: "firtName", lastName: "lastName")
    }

    private init(id: String, firstName: String, lastName: String, avatarURL: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.email = email
        self.profilePictureURL = avatarURL
        self.userFacade = FirebaseUserFacade()
        userFacade.delegate = self
    }

    var name: String {
       (self.firstName ?? "") + (self.lastName ?? "")
    }

    func subscribeToSignedIn(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $signedIn.sink(receiveValue: function)
    }
}

extension User: ALAuthDelegate {
    func signIn(withDetails details: ALLoginDetails) {
        userFacade.loginAsUser(
            withDetails: UserDetails(
                id: details.id,
                name: details.name,
                profilePictureURL: details.profilePictureURL))
    }

    func signOut() {
        // TODO: Implement signout
    }
}

extension User: UserFacadeDelegate {
    func updateUserData(withDetails details: UserDetails) {
        self.id = details.id
        self.firstName = details.name
        self.profilePictureURL = details.profilePictureURL
        self.signedIn = details.isLoggedIn
    }
}
