import Foundation

class LoginViewModel: ObservableObject {
    weak var delegate: LoggedInDelegate?
    var auth: ALAuth
    init(auth: ALAuth) {
        self.auth = auth
        auth.setUpGoogleHandler()
        auth.setUpFacebookHandler()
    }

    var text: String {
        "Login"
    }

    func didTapHomeButton() {
        delegate?.navigateToHomeFromLoggedIn()
    }

    func didTapGoogleLogin() {
        auth.initiateSignIn(type: ALAuthHandlerType.google)
    }

    func didTapFacebookLogin() {
        auth.initiateSignIn(type: ALAuthHandlerType.facebook)
    }

    func didTapBackButton() {
        delegate?.navigateToEntryFromLoggedIn()
    }
}
