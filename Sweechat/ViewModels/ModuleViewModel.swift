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
            user: User.createUnavailableInstance(),
            notificationMetadata: NotificationMetadata()
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
//        self.chatRoomViewModels = module.chatRooms.map {
//            ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
//        }
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
//            // TODO: Shouldn't remap all chatrooms (it's okay but we'll reload the views every time)
//            self.chatRoomViewModels = chatRooms.map {
//                ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
//            }
            self.handleChatRoomsChange(chatRooms: chatRooms)
        }
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
            if isFromNotif {
                AsyncHelper.checkAsync(interval: 0.1) {
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
            print("INI Uda duluan \(unwrappedDirectChatRoomViewModel.chatRoom.id)")
            self.directChatRoomViewModel = unwrappedDirectChatRoomViewModel
            self.isDirectChatRoomLoaded = true
        }
        return self.directChatRoomViewModel

    }

    private func handleChatRoomsChange(chatRooms: [ChatRoom]) {
        // TODO: Shouldn't remap all chatrooms (it's okay but we'll reload the views every time)
        let oldChatRoomIds = Set<Identifier<ChatRoom>>(self.chatRoomViewModels.map {
            $0.chatRoom.id
        })

        let allChatRoomIds = Set<Identifier<ChatRoom>>(chatRooms.map {
            $0.id
        })

        let newChatRoomIds = allChatRoomIds.filter({ !oldChatRoomIds.contains($0) })
        let newChatRooms = chatRooms.filter({ newChatRoomIds.contains($0.id) })
        print("this got changed")
        for newChatRoom in newChatRooms {
            print("SAVE ME FROM DEBug \(newChatRoom.id)")
        }
        print(newChatRooms)
        let newChatRoomViewModels: [ChatRoomViewModel] = newChatRooms.map {
            let newChatRoomViewModel = ChatRoomViewModelFactory.makeViewModel(chatRoom: $0, chatRoomCreator: self.createChatRoomViewModel)
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
    func resetNotificationMetadata() {
        self.isDirectChatRoomLoaded = false
        self.notificationMetadata.reset()
    }
}
