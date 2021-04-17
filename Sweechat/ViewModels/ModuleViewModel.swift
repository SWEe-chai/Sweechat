import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    let module: Module
    let notificationMetadata: NotificationMetadata
    var directChatRoomViewModel: ChatRoomViewModel

    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    @Published var isDirectChatRoomLoaded: Bool = false

    private var user: User
    private var subscribers: [AnyCancellable] = []

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

    var id: String {
        module.id.val
    }

    static func createUnavailableInstance() -> ModuleViewModel {
        ModuleViewModel(
            module: Module.createUnavailableInstance(),
            user: User.createUnavailableInstance(),
            notificationMetadata: NotificationMetadata()
        )
    }

    // MARK: Initialization

    init(module: Module, user: User, notificationMetadata: NotificationMetadata) {
        self.user = user
        self.module = module
        self.text = module.name
        self.directChatRoomViewModel = ChatRoomViewModel.createUnavailableInstance()
        self.notificationMetadata = notificationMetadata
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

    // MARK: Subscriptions

    private func initialiseSubscriber() {
        if !subscribers.isEmpty {
            return
        }
        initialiseNameSubscriber()
        initialiseChatRoomsSubscriber()
        initialiseNotificationMetadataSubscriber()
    }

    private func initialiseNameSubscriber() {
        let nameSubscriber = module.subscribeToName { newName in
            self.text = newName
        }

        subscribers.append(nameSubscriber)
    }

    private func initialiseChatRoomsSubscriber() {
        let chatRoomsSubscriber = module.subscribeToChatrooms { chatRooms in
            self.handleChatRoomsChange(chatRooms: chatRooms)
        }

        subscribers.append(chatRoomsSubscriber)
    }

    private func initialiseNotificationMetadataSubscriber() {
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
            if isFromNotif {
                AsyncHelper.checkAsync(interval: AsyncHelper.shortInterval) {
                    if self
                        .getChatRoomViewModel(
                            chatRoomId: self.notificationMetadata.directChatRoomId
                        ) != nil {
                        return false
                    }
                    return true
                }
            }
        }

        subscribers.append(notificationMetadataSubscriber)
    }

    // MARK: Private Function Helpers

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

    private func getChatRoomViewModel(chatRoomId: String) -> ChatRoomViewModel? {
        if let unwrappedDirectChatRoomViewModel = self.chatRoomViewModels.first(where: { $0.id == chatRoomId }) {
            self.directChatRoomViewModel = unwrappedDirectChatRoomViewModel
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
        self.isDirectChatRoomLoaded = false
        self.notificationMetadata.reset()
    }
}
