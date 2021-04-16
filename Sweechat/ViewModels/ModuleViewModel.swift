import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
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
    weak var delegate: ModuleViewModelDelegate?

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
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
        subscribers.append(notificationMetadataSubscriber)
    }

    func getChatRoomViewModel(chatRoomId: String) -> ChatRoomViewModel? {
        if let unwrappedDirectChatRoomViewModel = self.chatRoomViewModels.first(where: { $0.id == chatRoomId }) {
            self.directChatRoomViewModel = unwrappedDirectChatRoomViewModel
            self.isDirectChatRoomLoaded = true
        }
        return self.directChatRoomViewModel

    }

    private func handleChatRoomsChange(chatRooms: [ChatRoom]) {
        let oldChatRoomIds = Set<Identifier<ChatRoom>>(self.chatRoomViewModels.map {
            $0.chatRoom.id
        })

        let allChatRoomIds = Set<Identifier<ChatRoom>>(chatRooms.map {
            $0.id
        })

        let newChatRoomIds = allChatRoomIds.filter({ !oldChatRoomIds.contains($0) })
        let newChatRooms = chatRooms.filter({ newChatRoomIds.contains($0.id) })
        let newChatRoomViewModels: [ChatRoomViewModel] = newChatRooms.map {
            let newChatRoomViewModel = ChatRoomViewModelFactory
                .makeViewModel(
                    chatRoom: $0,
                    chatRoomCreator: self.createChatRoomViewModel
            )
            newChatRoomViewModel.delegate = self
            return newChatRoomViewModel
        }

        self.chatRoomViewModels.append(contentsOf: newChatRoomViewModels)
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
        self.delegate?.terminateNotificationReponse()
        self.isDirectChatRoomLoaded = false
        self.notificationMetadata.reset()
    }
}
