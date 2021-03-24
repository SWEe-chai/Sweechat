import Foundation

class ModuleViewModel: ObservableObject {
    var chatRoomViewModels: [ChatRoomViewModel]
    // TODO: When we have modules, text = name of module
    var text: String {
        "Module"
    }

    init(user: User) {
        // TODO: Load chat rooms from facade instead
        chatRoomViewModels = [
            ChatRoomViewModel(id: "2", user: user),
            ChatRoomViewModel(id: "3", user: user)
        ]
    }
}

// MARK: Identifiable
extension ModuleViewModel: Identifiable {
}
