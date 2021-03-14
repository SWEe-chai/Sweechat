import Foundation

class LoginViewModel: ObservableObject {
    weak var delegate: LoggedInDelegate?

    var text: String {
        "Login"
    }

    func didTapHomeButton() {
        delegate?.navigateToHome()
    }
}
