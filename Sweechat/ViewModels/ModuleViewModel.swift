import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
    private var user: User
    private var subscribers: [AnyCancellable] = []
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []

    var createChatRoomViewModel: CreateChatRoomViewModel {
        CreateChatRoomViewModel(
            module: module,
            user: user,
            members: module.members)
    }

    init(module: Module, user: User) {
        self.user = user
        self.module = module
        self.text = module.name
        self.chatRoomViewModels = module.chatRooms.map {
            ChatRoomViewModelFactory.makeViewModel(chatRoom: $0)
        }
        self.module.setModuleConnection()
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
            self.chatRoomViewModels = chatRooms.map {
                ChatRoomViewModelFactory.makeViewModel(chatRoom: $0)
            }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
    }

}

// MARK: Identifiable
extension ModuleViewModel: Identifiable {
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        self.count == other.count && self.sorted() == other.sorted()
    }
}
