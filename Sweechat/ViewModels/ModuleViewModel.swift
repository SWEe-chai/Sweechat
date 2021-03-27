import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    @Published var module: Module
    var text: String {
        module.name
    }
    var user: User
    var subscriber: AnyCancellable?

    var chatRoomViewModels: [ChatRoomViewModel] {
        module.chatRooms.map {
            ChatRoomViewModel(id: $0.id, name: $0.name, user: user)
        }
    }

    init(id: String, name: String, profilePictureUrl: String? = nil, user: User) {
        self.user = user
        self.module = Module(id: id, name: name, profilePictureUrl: profilePictureUrl)
        self.module.setModuleConnectionFor(user.id)
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        subscriber = module.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func handleCreateChatRoom() {
        // TODO: Currently chatroom for yourself only
        let users = [
            User(id: user.id)
        ]
        let chatRoom = ChatRoom(
            name: "Dummy Chat Room by Agnes \(UUID().uuidString)",
            members: users
        )
        self.module.store(chatRoom: chatRoom)
        for user in users {
            self.module.store(user: user)
        }
    }
}

// MARK: Identifiable
extension ModuleViewModel: Identifiable {
}
