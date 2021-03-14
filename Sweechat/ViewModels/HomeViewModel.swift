import Foundation

class HomeViewModel: ObservableObject {
    weak var delegate: HomeDelegate?

    var text: String {
        "Home"
    }

    func didTapModuleButton() {
        delegate?.navigateToModule()
    }

    func didTapSettingsButton() {
        delegate?.navigateToSettings()
    }
}
