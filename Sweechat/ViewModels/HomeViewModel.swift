import Foundation

class HomeViewModel: ObservableObject {
    weak var delegate: HomeDelegate?
    var user: User

    init(user: User) {
        self.user = user
    }

    var text: String {
        "Welcome home \(user.name)"
    }

    func didTapModuleButton() {
        delegate?.navigateToModuleFromHome()
    }

    func didTapSettingsButton() {
        delegate?.navigateToSettingsFromHome()
    }
}
