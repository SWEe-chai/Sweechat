import Foundation

class ModuleViewModel: ObservableObject {
    weak var delegate: ModuleDelegate?
    var text: String {
        "This is CS3217 - aka best mod"
    }

    func didTapChatRoomButton() {
        delegate?.navigateToChatRoomFromModule()
    }

    func didTapBackButton() {
        delegate?.navigateToHomeFromModule()
    }
}
