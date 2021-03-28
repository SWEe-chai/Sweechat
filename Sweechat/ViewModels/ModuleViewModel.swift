import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    @Published var otherMembersItemViewModels: [MemberItemViewModel] = []
    var user: User
    var subscribers: [AnyCancellable] = []

    init(module: Module, user: User) {
        self.user = user
        self.module = module
        self.text = module.name
        self.chatRoomViewModels = module.chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: self.user) }
        let a = module
            .members
            .filter { $0 != user }
        print(a.count)
        print(user.id)
        self.otherMembersItemViewModels = module
            .members
            .filter { $0 != user }
            .map { MemberItemViewModel(member: $0) }
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
        let chatRoomsSubscriber = module.subscribeToChatrooms { chatRooms in
            self.chatRoomViewModels = chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: self.user) }
        }
        let membersSubscriber = module.subscribeToMembers { members in
            self.otherMembersItemViewModels = members
                .filter { $0 != self.user }
                .map { MemberItemViewModel(member: $0) }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
        subscribers.append(membersSubscriber)
    }

    func handleCreateChatRoom() {
        // TODO: Currently chatroom for yourself only
        let user = User(id: self.user.id)
        user.setUserConnection()
        let users = [user]
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
