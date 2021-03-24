import Foundation

class SettingsViewModel: ObservableObject {
    weak var delegate: LoggedOutDelegate?

    var text: String {
        "Settings"
    }

    func didTapLogoutButton() {
        // TODO: Implement logout
    }
}
