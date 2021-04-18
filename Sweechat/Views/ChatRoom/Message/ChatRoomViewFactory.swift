import SwiftUI

struct ChatRoomViewFactory {
    static func makeView(
        viewModel: ChatRoomViewModel,
        isNavigationBarHidden: Binding<Bool>) -> some View {
        switch viewModel {
        case let viewModel as PrivateChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        case let viewModel as GroupChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        case let viewModel as ForumChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        case let viewModel as ThreadChatRoomViewModel:
            return AnyView(makeView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        default:
            fatalError("Abstract ChatRoomViewModel was instantiated!")
        }
    }

    static func makeView(viewModel: ThreadChatRoomViewModel, isNavigationBarHidden: Binding<Bool>) -> some View {
        ChatRoomView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden)
    }

    static func makeView(viewModel: PrivateChatRoomViewModel, isNavigationBarHidden: Binding<Bool>) -> some View {
        ChatRoomView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden)
    }

    static func makeView(viewModel: GroupChatRoomViewModel, isNavigationBarHidden: Binding<Bool>) -> some View {
        switch viewModel.permissions {
        case .readOnly:
            return AnyView(AnnouncementView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        default:
            return AnyView(ChatRoomView(viewModel: viewModel, isNavigationBarHidden: isNavigationBarHidden))
        }
    }

    static func makeView(viewModel: ForumChatRoomViewModel, isNavigationBarHidden: Binding<Bool>) -> some View {
        ForumChatRoomView(viewModel: viewModel,
                          isNavigationBarHidden: isNavigationBarHidden)
    }
}
