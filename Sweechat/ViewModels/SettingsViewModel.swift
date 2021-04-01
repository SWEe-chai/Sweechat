import Foundation

class SettingsViewModel: ObservableObject {
    weak var delegate: SettingsViewModelDelegate?

    var text: String {
        "Settings"
    }

    func didTapLogoutButton() {
        delegate?.signOut()
    }
}
