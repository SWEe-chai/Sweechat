import SwiftUI

struct CreateChatRoomToolbarView: View {
    var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool
    let moduleName: String

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
                                    isShowing: $isShowing, moduleName: moduleName)))
            if viewModel.canCreateForum {
                NavigationLink("Forum",
                               destination:
                                LazyNavView(
                                    ChooseChatRoomMembersView(
                                        viewModel: viewModel,
                                        viewAfterChoosingMembers:
                                            AnyView(LazyNavView(CreateForumView(
                                                                    viewModel: viewModel,
                                                                    isShowing: $isShowing))),
                                        isShowing: $isShowing, moduleName: moduleName)))
            }
        }
    }
}
