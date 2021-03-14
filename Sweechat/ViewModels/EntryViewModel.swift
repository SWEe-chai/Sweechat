import Foundation

class EntryViewModel: ObservableObject {
    var delegate: EntryDelegate?

    var text: String {
        "Entry"
    }

    func didTapLoginButton() {
        delegate?.navigateToLogin()
    }

    func didTapRegistrationButton() {
        delegate?.navigateToRegistration()
    }
}
