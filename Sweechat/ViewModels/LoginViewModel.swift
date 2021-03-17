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
        delegate?.navigateToHome()
    }

    func didTapGoogleLogin() {
        auth.getHandlerUI(type: .google).initiateSignIn()
    }

    func didTapFacebookLogin() {
        auth.getHandlerUI(type: .facebook).initiateSignIn()
    }
}
