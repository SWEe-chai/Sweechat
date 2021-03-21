import Combine

class User: ObservableObject {
    static let unvailableUserId = ""
    static let unvailableUserName = "Unavailable User"

    @Published var id: String
    @Published var name: String
    @Published var profilePictureUrl: String?
    private var userFacade: UserFacade
    private var isLoggedInSubscribers: [((Bool) -> Void)] = []

    static func createUnavailableUser() -> User {
        User(details: UserRepresentation(id: unvailableUserId, name: unvailableUserName))
    }

    init(details: UserRepresentation) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
        self.userFacade = FirebaseUserFacade(userId: details.id)
        userFacade.delegate = self
    }
}

// MARK: Equatable
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: UserFacadeDelegate
extension User: UserFacadeDelegate {
    func updateUserData(withDetails details: UserRepresentation) {
        self.id = details.id
        self.name = details.name
        self.profilePictureUrl = details.profilePictureUrl
    }
}
