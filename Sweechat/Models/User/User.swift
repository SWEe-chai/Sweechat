import Combine

class User: ObservableObject {
    @Published var id: String
    @Published var username: String?
    @Published var email: String
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var profilePictureURL: String?
    @Published var signedIn: Bool = false

    init(id: String, firstName: String, lastName: String, avatarURL: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.email = email
        self.profilePictureURL = avatarURL
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
        id = details.id
        firstName = details.name
        signedIn = true
    }

    func signOut() {
        // TODO: Implement signout
    }
}
