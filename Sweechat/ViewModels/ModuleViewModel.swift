import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    var module: Module
    private var user: User
    private var subscribers: [AnyCancellable] = []
    var id: String {
        module.id.val
    }
    var directChatRoomViewModel: ChatRoomViewModel
    var notificationMetadata: NotificationMetadata
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    @Published var isDirectChatRoomLoaded: Bool = false

    static func createUnavailableInstance() -> ModuleViewModel {
        ModuleViewModel(
            module: Module.createUnavailableInstance(),
            user: User.createUnavailableInstance(),
            notificationMetadata: NotificationMetadata()
        )
    }

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
            members: module.members
        )
    }

    init(module: Module, user: User, notificationMetadata: NotificationMetadata) {
        print("init module view model \(module.id)")
        self.user = user
        self.module = module
        self.text = module.name
        self.directChatRoomViewModel = ChatRoomViewModel.createUnavailableInstance()
        self.notificationMetadata = NotificationMetadata()
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
        let chatRoomsSubscriber = module.subscribeToChatrooms { chatRooms in
            self.handleChatRoomsChange(chatRooms: chatRooms)
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
    }

    func loadThisChatRoom(chatRoomId: String) {
        AsyncHelper.checkAsync(interval: AsyncHelper.shortInterval) {
            if self
                .getChatRoomViewModel(
                    chatRoomId: chatRoomId
                ) != nil {
                return false
            }
            return true
        }
    }

    func getOut() {
        self.isDirectChatRoomLoaded = false
    }

    private func handleChatRoomsChange(chatRooms: [ChatRoom]) {
        // Remove deleted chatrooms
        let allChatRoomsIds: Set<Identifier<ChatRoom>> = Set(chatRooms.map { $0.id })
        self.chatRoomViewModels = self.chatRoomViewModels.filter { allChatRoomsIds.contains($0.chatRoom.id) }

        // Add new chatrooms
        let oldChatRoomIds = Set(self.chatRoomViewModels.map { $0.chatRoom.id })
        let newChatRoomVMs: [ChatRoomViewModel] = chatRooms
            .filter { !oldChatRoomIds.contains($0.id) }
            .map {
                let newChatRoomViewModel = ChatRoomViewModelFactory
                    .makeViewModel(
                        chatRoom: $0,
                        chatRoomCreator: self.createChatRoomViewModel
                )
                newChatRoomViewModel.delegate = self
                return newChatRoomViewModel
            }
        self.chatRoomViewModels.append(contentsOf: newChatRoomVMs)
    }

    func getChatRoomViewModel(chatRoomId: String) -> ChatRoomViewModel? {
        if let unwrappedDirectChatRoomViewModel = self.chatRoomViewModels.first(where: { $0.id == chatRoomId }) {
            self.directChatRoomViewModel = unwrappedDirectChatRoomViewModel
            print("set direct chatroom = true")
            self.isDirectChatRoomLoaded = true
        }
        return self.directChatRoomViewModel
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

extension ModuleViewModel: ChatRoomViewModelDelegate {
    func terminateNotificationResponse() {
//        self.isDirectChatRoomLoaded = false
//        self.notificationMetadata.reset()
    }
}
