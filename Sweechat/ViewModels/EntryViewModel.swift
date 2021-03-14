import Foundation

class EntryViewModel: ObservableObject {
    weak var delegate: EntryDelegate?

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
