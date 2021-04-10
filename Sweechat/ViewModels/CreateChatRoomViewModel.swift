import SwiftUI
import Combine

class CreateChatRoomViewModel: ObservableObject {
    var module: Module
    var user: User
    var memberListener: AnyCancellable?

    var otherUsersViewModels: [MemberItemViewModel]

    @Published var isWritable: Bool = true

    // Creation permission
    var canCreateForum: Bool {
        ModulePermission.canCreateForum(permission: module.currentUserPermission)
    }

    private var otherChosenMembers: [User] {
        otherUsersViewModels.filter { $0.isSelected }.map { $0.member }
    }

    init(module: Module, user: User, members: [User]) {
        self.module = module
        self.user = user
        self.otherUsersViewModels = members
            .filter { $0.id != user.id }
            .map { MemberItemViewModel(member: $0) }
    }

    // TODO: Consider grouping all three methods as one, have a function in the
    func createPrivateGroupChatWith(memberViewModel: MemberItemViewModel) {
        // Return if private chat already exists
        for chatroom in module.chatRooms {
            if let privateChatRoom = chatroom as? PrivateChatRoom,
               privateChatRoom.otherUser == memberViewModel.member {
                // This means that the private chat has already been created
                return
            }
        }
        let membersInPrivateChat = [user, memberViewModel.member]
        let memberPermissions = membersInPrivateChat
            .map { UserPermissionPair(userId: $0.id, permissions: ChatRoomPermission.readWrite) }

        // This means that Chatroom does not exist
        let newPrivateChatRoom = PrivateChatRoom(
            currentUser: user,
            otherUser: memberViewModel.member)
        module.store(chatRoom: newPrivateChatRoom,
                     userPermissions: memberPermissions)
    }

    func createForum(forumName: String) {
        var members: [User] = otherChosenMembers
        var memberPermissions = members.map {
            UserPermissionPair(
                userId: $0.id,
                permissions: ChatRoomPermission.readWrite)
        }
        members.append(user)
        // Creator gets all permissions
        memberPermissions.append(UserPermissionPair(userId: user.id, permissions: ChatRoomPermission.all))
        let newForumChat = ForumChatRoom(
            name: forumName,
            members: members,
            currentUser: user)
        module.store(chatRoom: newForumChat,
                     userPermissions: memberPermissions)
    }

    func createGroupChat(groupName: String) {
        var members: [User] = otherChosenMembers
        var memberPermissions = members.map {
            UserPermissionPair(
                userId: $0.id,
                permissions: getOtherUsersPermissions())
        }
        members.append(user)
        // Creator gets all permissions
        memberPermissions.append(UserPermissionPair(userId: user.id, permissions: ChatRoomPermission.all))
        let newGroupChatRoom = GroupChatRoom(
            name: groupName,
            members: members,
            currentUser: user,
            currentUserPermission: ChatRoomPermission.all)
        module.store(chatRoom: newGroupChatRoom,
                     userPermissions: memberPermissions)

    }

    private func getOtherUsersPermissions() -> ChatRoomPermissionBitmask {
        ChatRoomPermission.read
            | (isWritable ? ChatRoomPermission.write : 0)
    }

    func toggleIsWritable() {
        isWritable.toggle()
    }
}

// MARK: ForumViewModelDelegate
extension CreateChatRoomViewModel: ForumViewModelDelegate {
    func createThreadChatRoom(id: String, currentUser: User, forumMembers: [User]) {
        let threadChatRoom = ThreadChatRoom(postId: id, sender: currentUser, forumMembers: forumMembers)
        let permissionPairs = forumMembers.map {
            UserPermissionPair(userId: $0.id, permissions: ChatRoomPermission.readWrite)
        }
        module.store(chatRoom: threadChatRoom, userPermissions: permissionPairs)
    }
}
