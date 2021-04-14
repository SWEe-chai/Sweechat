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
    
    static func createUnavailableInstance() -> ModuleViewModel {
        ModuleViewModel(
            module: Module.createUnavailableInstance(),
            user: User.createUnavailableInstance()
        )
    }

    var createChatRoomViewModel: CreateChatRoomViewModel {
        CreateChatRoomViewModel(
            module: module,
            user: user,
            members: module.members)
    }

    init(module: Module, user: User, notificationMetadata: NotificationMetadata) {
        self.user = user
        self.module = module
        self.text = module.name
        self.directChatRoomViewModel = ChatRoomViewModel.createUnavailableInstance()
        self.notificationMetadata = notificationMetadata
        self.chatRoomViewModels = module.chatRooms.map {
            ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
        }
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
            // TODO: Shouldn't remap all chatrooms (it's okay but we'll reload the views every time)
            self.chatRoomViewModels = chatRooms.map {
                ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
            }
        }
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
                if isFromNotif {
                    AsyncHelper.checkAsync(interval: 0.5) {
                        if self
                            .getModuleViewModel(
                                moduleId: self.notificationMetadata.directModuleId
                            ) != nil {
                            return false
                        }
                        return true
                    }
                }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(chatRoomsSubscriber)
    }

    func getChatRoomViewModel(chatRoomId: String) -> ChatRoomViewModel? {
        self.chatRoomViewModels.first(where: { $0.id == chatRoomId })
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
