import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    let module: Module
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
            user: User.createUnavailableInstance()
        )
    }

    // MARK: Initialization

    init(module: Module, user: User) {
        self.user = user
        self.module = module
        self.text = module.name
        self.directChatRoomViewModel = ChatRoomViewModel.createUnavailableInstance()
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

    func loadThisChatRoom(chatRoomId: String) {
        AsyncHelper.checkAsync(interval: AsyncHelper.shortInterval) {
            if self
                .setChatRoomViewModel(
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
                let viewModel = ChatRoomViewModelFactory
                    .makeViewModel(
                        chatRoom: $0,
                        chatRoomCreator: self.createChatRoomViewModel
                )
                viewModel.delegate = self
                return viewModel
            }
        self.chatRoomViewModels.append(contentsOf: newChatRoomVMs)
        self.sortChatRooms()
    }

    private func setChatRoomViewModel(chatRoomId: String) -> ChatRoomViewModel? {
        if let unwrappedDirectChatRoomViewModel = self.chatRoomViewModels.first(where: { $0.id == chatRoomId }) {
            self.directChatRoomViewModel = unwrappedDirectChatRoomViewModel
            self.isDirectChatRoomLoaded = true
        }
        return self.directChatRoomViewModel
    }
}

// MARK
extension ModuleViewModel: ChatRoomViewModelDelegate {
    func sortChatRooms() {
        self.chatRoomViewModels.sort { lhs, rhs in
            let lhsDate: Date = lhs.lastestMessageTime ?? lhs.creationTime
            let rhsDate: Date = rhs.lastestMessageTime ?? rhs.creationTime
            return lhsDate > rhsDate
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
