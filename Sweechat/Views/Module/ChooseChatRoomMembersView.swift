import SwiftUI

struct ChooseChatRoomMembersView: View {
    var viewModel: CreateChatRoomViewModel
    var viewAfterChoosingMembers: AnyView
    @Binding var isShowing: Bool

    var body: some View {
        ScrollView {
            ForEach(viewModel.otherUsersViewModels) { memberItemViewModel in
                MemberItemSelectView(viewModel: memberItemViewModel)
                    .padding()
            }
        }
        .background(ColorConstant.base)
        .toolbar {
            NavigationLink("Next", destination: viewAfterChoosingMembers)
        }.navigationTitle("Group Members")

    }
}

 struct ChooseChatRoomMembersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseChatRoomMembersView(
                viewModel: CreateChatRoomViewModel(
                    module: Module(id: "", name: "", currentUser: User(id: "1", name: "One Natasya")),
                    user: User(id: "1", name: "One Natasya"),
                    members: [
                        User(id: "1", name: "One Natasya"),
                        User(id: "2", name: "Christian James Welly"),
                        User(id: "2", name: "Hai Nguyen")
                    ]),
                viewAfterChoosingMembers: AnyView(Text("Hello")),
                isShowing: .constant(true))
        }
    }
 }
