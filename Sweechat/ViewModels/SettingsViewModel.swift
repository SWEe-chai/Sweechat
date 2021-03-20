import Foundation

class SettingsViewModel: ObservableObject {
    weak var delegate: LoggedOutDelegate?

    var text: String {
        "Settings"
    }

    func didTapLogoutButton() {
        delegate?.navigateToEntryFromLoggedOut()
    }

    func didTapBackButton() {
        delegate?.navigateToHomeFromLoggedOut()
    }
}
