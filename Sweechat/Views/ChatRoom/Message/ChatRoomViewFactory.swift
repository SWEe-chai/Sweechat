import SwiftUI

struct ChatRoomViewFactory {
    static func makeView(viewModel: ChatRoomViewModel) -> some View {
        switch viewModel {
        case let viewModel as PrivateChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel))
        case let viewModel as GroupChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel))
        case let viewModel as ForumChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel))
        case let viewModel as ThreadChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel))
        default:
            fatalError("Abstract ChatRoomViewModel was instantiated!")
        }
    }

    static func makeView(viewModel: ThreadChatRoomViewModel) -> some View {
        ChatRoomView(viewModel: viewModel)
    }

    static func makeView(viewModel: PrivateChatRoomViewModel) -> some View {
        ChatRoomView(viewModel: viewModel)
    }

    static func makeView(viewModel: GroupChatRoomViewModel) -> some View {
        switch viewModel.permissions {
        case .readOnly:
            return AnyView(AnnouncementView(viewModel: viewModel))
        default:
            return AnyView(ChatRoomView(viewModel: viewModel))
        }
    }

    static func makeView(viewModel: ForumChatRoomViewModel) -> some View {
        ForumChatRoomView(viewModel: viewModel)
    }
}
