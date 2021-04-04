import SwiftUI

struct CreateGroupChatView: View {
    @State var groupName: String = ""
    @ObservedObject var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Text("Set Group Name")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding()
            HStack {
                ChatRoomNameTextField(placeholder: "Group name...", name: $groupName)
            }
            .frame(idealHeight: 20, maxHeight: 50)
            .padding()
            Divider().padding()
            Text("Set permissions for other users").font(FontConstant.ModuleDescription)
            PermissionItemView(
                isLit: $viewModel.isWritable,
                onTap: viewModel.toggleIsWritable,
                text: "Send messages")
            Spacer()
        }
        .navigationTitle("Create Group")
        .toolbar {
            Button("Create") {
                viewModel.createGroupChat(groupName: groupName)
                isShowing = false
                groupName = ""
            }.disabled(groupName.isEmpty)
        }
        .background(ColorConstant.base)
    }
}

struct PermissionItemView: View {
    @Binding var isLit: Bool
    var onTap: () -> Void
    var text: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(isLit ? ColorConstant.primary : ColorConstant.transparent)
                .cornerRadius(5)
                .frame(width: 20, height: 20, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 1)
                )
            Text(text)
        }.onTapGesture {
            onTap()
        }
    }
}

struct CreateGroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateGroupChatView(viewModel: CreateChatRoomViewModel(
                module: Module(id: "", name: "", currentUser: User(id: "1", name: "One Natasya")),
                user: User(id: "1", name: "One Natasya"),
                members: [
                    User(id: "1", name: "One Natasya"),
                    User(id: "2", name: "Two Welly")
                ]), isShowing: .constant(true))
        }
    }
}
