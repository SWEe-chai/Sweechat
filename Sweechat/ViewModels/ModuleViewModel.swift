import Foundation

class ModuleViewModel: ObservableObject {
    weak var delegate: ModuleDelegate?
    var text: String {
        "Module"
    }

    func didTapChatRoomButton() {
        delegate?.navigateToChatRoomFromModule()
    }

    func didTapBackButton() {
        delegate?.navigateToHomeFromModule()
    }
}
