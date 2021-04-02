import SwiftUI

struct ChooseGroupChatMembersView: View {
    var viewModel: CreateChatRoomViewModel
    var viewAfterChoosingMembers: AnyView
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            ForEach(viewModel.otherUsersViewModels) { memberItemViewModel in
                MemberItemView(viewModel: memberItemViewModel)
                    .padding([.top])
            }
            Spacer()
        }
        .toolbar {
            NavigationLink("Next", destination: viewAfterChoosingMembers)
        }.navigationTitle("Group Members")

    }
}

// struct ChooseGroupChatMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ChooseGroupChatMembersView(
//                viewModel: CreateChatRoomViewModel(
//                    module: Module(id: "", name: "", currentUser: User(id: "1", name: "One Natasya")),
//                    user: User(id: "1", name: "One Natasya"),
//                    members: [
//                        User(id: "1", name: "One Natasya"),
//                        User(id: "2", name: "Two Welly")
//                    ]),
//                isShowing: .constant(true))
//        }
//    }
// }
