import Foundation

class LoginViewModel: ObservableObject {
    let notificationMetadata: NotificationMetadata

    @Published var isLoggedIn = false

    private let auth: ALAuth
    private var user: User?

    var loginButtonViewModels: [LoginButtonViewModel] {
        auth.authHandlers.map({ LoginButtonViewModel(authHandler: $0) })
    }

    var homeViewModel: HomeViewModel {
        let viewModel = HomeViewModel(user: getUnwrappedUser(), notificationMetadata: notificationMetadata)
        viewModel.delegate = self
        return viewModel
    }

    // MARK: Initialization

    init(notificationMetadata: NotificationMetadata) {
        self.auth = ALAuth()
        self.notificationMetadata = notificationMetadata
        auth.delegate = self
        auth.signInWithPreviousSession()
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
        let id = Identifier<User>(val: details.id)
        user = User(id: id,
                    name: details.name,
                    profilePictureUrl: details.profilePictureUrl)
        user?.setUserConnection()
        isLoggedIn = true
    }

    func signOut() {
        auth.signOut()
        isLoggedIn = false
        user = nil
    }
}

// MARK: HomeViewModelDelegate
extension LoginViewModel: HomeViewModelDelegate {
}
