import Foundation

class LoginViewModel: ObservableObject {
    weak var delegate: LoggedInDelegate?
    private var auth: ALAuth
    private var user: User?
    @Published var isLoggedIn = false
    var loginButtonViewModels: [LoginButtonViewModel] {
        auth.authHandlers.map({ LoginButtonViewModel(authHandler: $0) })
    }

    init() {
        self.auth = ALAuth()
        auth.delegate = self
    }

    var text: String {
        "Login"
    }

    func getHomeView() -> HomeView {
        HomeView(viewModel: HomeViewModel(user: getUnwrappedUser()))
    }

    private func getUnwrappedUser() -> User {
        // This is so that we can control where user is unwrapped
        guard let user = self.user else {
            fatalError("Unwrapped user but user is nil")
        }
        return user
    }
}

// MARK: ALAuthDelegate
extension LoginViewModel: ALAuthDelegate {
    func signIn(withDetails details: ALLoginDetails) {
        user = User(details: UserRepresentation(
                        id: details.id,
                        name: details.name))
        user?.initiateListeningToUser()
        isLoggedIn = true
    }

    func signOut() {
        // TODO: Implement sign out
    }
}
