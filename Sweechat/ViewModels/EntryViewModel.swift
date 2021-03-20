import Foundation

class EntryViewModel: ObservableObject {
    weak var delegate: EntryDelegate?

    var text: String {
        "Entry"
    }

    func didTapLoginButton() {
        delegate?.navigateToLoginFromEntry()
    }

    func didTapRegistrationButton() {
        delegate?.navigateToRegistrationFromEntry()
    }
}
