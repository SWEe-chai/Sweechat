import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
    private var user: User
    private var subscribers: [AnyCancellable] = []
    var id: String {
        module.id.val
    }
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []

    var privateChatRoomVMs: [PrivateChatRoomViewModel] {
        chatRoomViewModels.compactMap { $0 as? PrivateChatRoomViewModel }
    }
    var groupChatRoomVMs: [GroupChatRoomViewModel] {
        chatRoomViewModels.compactMap { $0 as? GroupChatRoomViewModel }
    }
    var forumChatRoomVMs: [ForumChatRoomViewModel] {
        chatRoomViewModels.compactMap { $0 as? ForumChatRoomViewModel }
    }
    var starredModuleVMs: [ChatRoomViewModel] {
        chatRoomViewModels.filter { $0.isStarred }
    }

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
            ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
        }
        initialiseSubscriber()
    }

    func getChatRoomList(type: ChatRoomListType) -> [ChatRoomViewModel] {
        switch type {
        case .forum:
            return forumChatRoomVMs
        case .privateChat:
            return privateChatRoomVMs
        case .groupChat:
            return groupChatRoomVMs
        case .starred:
            // TODO: Add actual implementation
            return starredModuleVMs
        }
    }

    func initialiseSubscriber() {
        if !subscribers.isEmpty {
            return
        }
        let nameSubscriber = module.subscribeToName { newName in
            self.text = newName
        }
        let chatRoomsSubscriber = module.subscribeToChatrooms {
            self.handleChatRoomsChange(chatRooms: $0)
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
    }

    private func handleChatRoomsChange(chatRooms: [ChatRoom]) {
        // TODO: Shouldn't remap all chatrooms (it's okay but we'll reload the views every time)
        self.chatRoomViewModels = chatRooms.map {
            ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
        }
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
