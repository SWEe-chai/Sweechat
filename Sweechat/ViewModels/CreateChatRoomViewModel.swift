import SwiftUI
import Combine

class CreateChatRoomViewModel: ObservableObject {
    var module: Module
    var user: User
    var memberListener: AnyCancellable?

    var otherUsersViewModels: [MemberItemViewModel]

    @Published var isWritable: Bool = true

    init(module: Module, user: User, members: [User]) {
        self.module = module
        self.user = user
        self.otherUsersViewModels = members
            .filter { $0.id != user.id }
            .map { MemberItemViewModel(member: $0) }
    }

    func createPrivateGroupChatWith(memberViewModel: MemberItemViewModel) {
        // Return if private chat already exists
        for chatroom in module.chatRooms {
            if let privateChatRoom = chatroom as? PrivateChatRoom,
               privateChatRoom.otherUser == memberViewModel.member {
                // This means that the private chat has already been created
                return
            }
        }

        // This means that Chatroom does not exist
        let newPrivateChatRoom = PrivateChatRoom(
            name: memberViewModel.memberName,
            members: [user, memberViewModel.member],
            currentUser: user)
        module.store(chatRoom: newPrivateChatRoom)
    }

    func createGroupChat(groupName: String) {
        var members: [User] = otherUsersViewModels
            .filter { $0.isSelected }
            .map { $0.member }
        members.append(user)
        let newGroupChatRoom = GroupChatRoom(name: groupName, members: members, currentUser: user)
        module.store(chatRoom: newGroupChatRoom)

    }

    func toggleIsWritable() {
        isWritable.toggle()
    }
}
