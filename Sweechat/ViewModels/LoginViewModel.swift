import Foundation

class LoginViewModel: ObservableObject {
    weak var delegate: LoggedInDelegate?
    private var auth: ALAuth
    var loginButtonViewModels: [LoginButtonViewModel] {
        auth.authHandlers.map({ LoginButtonViewModel(authHandler: $0) })
    }

    init(auth: ALAuth) {
        self.auth = auth
    }

    var text: String {
        "Login"
    }

    func didTapBackButton() {
        delegate?.navigateToEntryFromLoggedIn()
    }
}
