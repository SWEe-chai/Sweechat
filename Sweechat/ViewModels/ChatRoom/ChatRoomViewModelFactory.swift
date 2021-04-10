import os

class ChatRoomViewModelFactory {
    static func makeViewModel(chatRoom: ChatRoom, chatRoomCreator creator: ThreadCreator) -> ChatRoomViewModel {
        switch chatRoom {
        case let chatRoom as PrivateChatRoom:
            return PrivateChatRoomViewModel(privateChatRoom: chatRoom)
        case let chatRoom as GroupChatRoom:
            return GroupChatRoomViewModel(groupChatRoom: chatRoom)
        case let chatRoom as ForumChatRoom:
            return ForumChatRoomViewModel(forumChatRoom: chatRoom, creator: creator)
        case let chatRoom as ThreadChatRoom:
            fatalError("ChatRoomViewModelFactory trying to get a thread chat room")
        default:
            fatalError("Abstract type ChatRoom was initiated")
        }
    }
}
