import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    @Published var otherMembersItemViewModels: [MemberItemViewModel] = []
    @Published var isChatRoomSelected: Bool
    var user: User
    var subscribers: [AnyCancellable] = []

    init(module: Module, user: User) {
        self.user = user
        self.module = module
        self.text = module.name
        self.isChatRoomSelected = false
        self.chatRoomViewModels = module.chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: self.user) }
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

//    func getChatRoom(for members: [User]) -> ChatRoom {
//        let currentChatRoom = self.module.chatRooms.filter { $0.members.containsSameElements(as: members) }
//        return !currentChatRoom.isEmpty ? currentChatRoom[0] : ChatRoom.createUnavailableChatRoom()
//    }

    func getSelectedMembers() -> [User] {
        var selectedMembers = self
            .otherMembersItemViewModels.filter { $0.isSelected }
            .map { $0.member }
        selectedMembers.append(user)
        return selectedMembers
    }

    func handleCreateChatRoom(chatRoom: ChatRoom) {
        let currentChatRoom = self.module.chatRooms.filter {
            print($0.members)
            print(chatRoom.members)
            return $0.members.containsSameElements(as: chatRoom.members)

        }
        if currentChatRoom.isEmpty {
            print("AYOLAAAA")
            self.module.store(chatRoom: chatRoom)
        }
        chatRoom.setChatRoomConnection()
        self.isChatRoomSelected = true
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
