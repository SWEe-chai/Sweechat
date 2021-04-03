class ChatRoomViewModelFactory {
    static func makeViewModel(chatRoom: ChatRoom) -> ChatRoomViewModel {
        switch chatRoom {
        case let chatRoom as PrivateChatRoom:
            return PrivateChatRoomViewModel(privateChatRoom: chatRoom)
        case let chatRoom as GroupChatRoom:
            return GroupChatRoomViewModel(groupChatRoom: chatRoom)
        case let chatRoom as ForumChatRoom:
            return ForumChatRoomViewModel(forumChatRoom: chatRoom)
        default:
            fatalError("Abstract type ChatRoom was initiated")
        }
    }
}
