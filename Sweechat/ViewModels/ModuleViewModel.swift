import Foundation

class ModuleViewModel: ObservableObject {
    weak var delegate: ModuleDelegate?
    // TODO: When we have modules, this should be the name of the module
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

extension ModuleViewModel: Identifiable {
}
