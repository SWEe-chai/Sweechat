import Foundation

class ModuleViewModel: ObservableObject {
    weak var delegate: ModuleDelegate?
    var chatRoomViewModels: [ChatRoomViewModel]
    // TODO: When we have modules, text = name of module
    var text: String {
        "Module"
    }

    init(user: User) {
        chatRoomViewModels = [
            ChatRoomViewModel(id: "3", user: user)
        ]
    }
}

extension ModuleViewModel: Identifiable {
}
