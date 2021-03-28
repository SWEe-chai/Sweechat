import Combine

class User: ObservableObject {
    static let unvailableUserId = ""
    static let unvailableUserName = "Unavailable User"

    @Published var id: String
    @Published var name: String
    @Published var profilePictureUrl: String?
    private var userFacade: UserFacade?
    private var isLoggedInSubscribers: [((Bool) -> Void)] = []

    static func createUnavailableUser() -> User {
        let user = User(id: unvailableUserId, name: unvailableUserName)
        user.setUserConnection()
        return user
    }

    init(id: String) {
        self.id = id
        self.name = ""
        self.profilePictureUrl = ""
    }

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
    }

    func setUserConnection() {
        self.userFacade = FirebaseUserFacade(userId: id)
        userFacade?.delegate = self
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
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
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
