import Combine
import Foundation

class ModuleViewModel: ObservableObject {
    private var module: Module
    private var user: User
    private var subscribers: [AnyCancellable] = []
    @Published var text: String
    @Published var chatRoomViewModels: [ChatRoomViewModel] = []
    @Published var otherMembersItemViewModels: [MemberItemViewModel] = []
    @Published var currentSelectedMembers: [User] {
        didSet {
            otherMembersItemViewModels
                .forEach { $0.isSelected = currentSelectedMembers.contains($0.member) }
        }
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
        self.currentSelectedMembers = []

        self.chatRoomViewModels = module.chatRooms.map { ChatRoomViewModel(chatRoom: $0, user: user) }
        self.otherMembersItemViewModels = module
            .members
            .filter { $0 != user }
            .map { MemberItemViewModel(member: $0) }
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

    private func getSelectedMembers() -> [User] {
        var selectedMembers = self
            .otherMembersItemViewModels.filter { $0.isSelected }
            .map { $0.member }
        selectedMembers.append(user)
        return selectedMembers
    }

    func handleMemberSelection(_ user: User) {
        self.currentSelectedMembers.append(user)
    }

//    func handleCreateChatRoom(name: String) {
//        let chatRoom = GroupChatRoom(name: name, members: getSelectedMembers())
//        if chatRoom.members.count > 2 {
//            let name = !name.isEmpty ? name : chatRoom.members.map { $0.name }.joined(separator: ", ")
//            chatRoom.name = name
//            self.module.store(chatRoom: chatRoom)
//            chatRoom.setChatRoomConnection()
//        } else {
//            let existingChatRooms = self.module.chatRooms.filter {
//                $0.members.containsSameElements(as: chatRoom.members)
//            }
//            if existingChatRooms.isEmpty {
//                self.module.store(chatRoom: chatRoom)
//                chatRoom.setChatRoomConnection()
//            }
//        }
//        self.currentSelectedMembers = []
//    }
}

// MARK: Identifiable
extension ModuleViewModel: Identifiable {
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        self.count == other.count && self.sorted() == other.sorted()
    }
}
