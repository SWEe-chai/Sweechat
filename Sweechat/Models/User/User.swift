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
        User(id: unvailableUserId, name: unvailableUserName)
    }

//    init(details: UserRepresentation) {
//        self.id = details.id
//        self.name = details.name
//        self.profilePictureUrl = details.profilePictureUrl
//        self.userFacade = FirebaseUserFacade(userId: details.id)
//        userFacade.delegate = self
//    }
    
    init(id: String, name: String, profilePictureUrl: String? = "") {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.userFacade = FirebaseUserFacade(userId: id)
        userFacade.delegate = self
    }

    func initiateListeningToUser() {
        userFacade.loginAndListenToUser(
            User(
                id: id,
                name: name,
                profilePictureUrl: profilePictureUrl
            )
        )
    }

    func subscribeToName(function: @escaping (String) -> Void) -> AnyCancellable {
        $name.sink(receiveValue: function)
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
    
    func updateUser(user: User) {
        self.id = user.id
        self.name = user.name
        self.profilePictureUrl = user.profilePictureUrl
    }
}
