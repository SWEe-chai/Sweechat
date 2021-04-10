class ChatRoomViewModelFactory {
    static func makeViewModel(chatRoom: ChatRoom, inModule moduleVM: ModuleViewModel) -> ChatRoomViewModel {
        switch chatRoom {
        case let chatRoom as PrivateChatRoom:
            return PrivateChatRoomViewModel(privateChatRoom: chatRoom)
        case let chatRoom as GroupChatRoom:
            return GroupChatRoomViewModel(groupChatRoom: chatRoom)
        case let chatRoom as ForumChatRoom:
            return ForumChatRoomViewModel(forumChatRoom: chatRoom, delegate: moduleVM.createChatRoomViewModel)
        case let chatRoom as ThreadChatRoom:
            return ThreadChatRoomViewModel(threadChatRoom: chatRoom)
        default:
            fatalError("Abstract type ChatRoom was initiated")
        }
    }
}
