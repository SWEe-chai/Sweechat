import SwiftUI

struct CreateChatRoomToolbarView: View {
    var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool
    var body: some View {
        HStack {
            NavigationLink("Group",
                           destination:
                            LazyNavView(
                                ChooseChatRoomMembersView(
                                    viewModel: viewModel,
                                    viewAfterChoosingMembers:
                                        AnyView(LazyNavView(CreateGroupChatView(
                                                        viewModel: viewModel,
                                                        isShowing: $isShowing))),
                                    isShowing: $isShowing)))
            NavigationLink("Forum",
                           destination:
                            LazyNavView(
                                ChooseChatRoomMembersView(
                                    viewModel: viewModel,
                                    viewAfterChoosingMembers:
                                        AnyView(LazyNavView(CreateForumView(
                                                                viewModel: viewModel,
                                                                isShowing: $isShowing))),
                                    isShowing: $isShowing)))
        }
    }
}
