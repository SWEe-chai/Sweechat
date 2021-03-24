import Foundation

class ModuleViewModel: ObservableObject {
    var module: Module
    var chatRoomViewModels: [ChatRoomViewModel]
    // TODO: When we have modules, text = name of module
    var text: String {
        module.name
    }

    init(id: String, name: String, profilePictureUrl: String? = nil, user: User) {
        // TODO: Load chat rooms from facade instead
        module = Module.of(id: id, name: name, profilePictureUrl: profilePictureUrl, for: user)
//        chatRoomViewModels = [
//            ChatRoomViewModel(id: "2", user: user),
//            ChatRoomViewModel(id: "3", user: user)
//        ]
        chatRoomViewModels = module.chatRooms.map {
            ChatRoomViewModel(id: $0.id, name: $0.name, user: user)
        }
    }
}

// MARK: Identifiable
extension ModuleViewModel: Identifiable {
}
