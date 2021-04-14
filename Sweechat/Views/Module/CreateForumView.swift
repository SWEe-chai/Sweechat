import SwiftUI

struct CreateForumView: View {
    @State var forumName: String = ""
    @ObservedObject var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Forum Name")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding(.top)
            HStack {
                ChatRoomNameTextField(placeholder: "Forum name...", name: $forumName)
            }
            Divider()
            StarTickBoxView(viewModel: viewModel)
            Spacer()
        }
        .padding()
        .background(ColorConstant.base)
        .navigationTitle("Create Forum")
        .toolbar {
            Button("Create") {
                viewModel.createForum(forumName: forumName)
                isShowing = false
                forumName = ""
            }.disabled(forumName.isEmpty)
        }
    }
}
