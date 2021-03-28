import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    @Published var module: Module
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    var user: User
    var subscribers: [AnyCancellable] = []

    init(module: Module, user: User) {
        self.user = user
        self.module = module
        self.text = module.name
        self.chatRoomViewModels = module.chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: self.user) }
        self.module.setModuleConnectionFor(user.id)
        initialiseSubscriber()
    }

    func initialiseSubscriber() {
        if !subscribers.isEmpty {
            return
        }
        let nameSubscriber = module.subscribeToName { newName in
            self.text = newName
        }
        let chatRoomSubscriber = module.subscribeToChatrooms { chatRooms in
            self.chatRoomViewModels = chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: self.user) }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomSubscriber)
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
