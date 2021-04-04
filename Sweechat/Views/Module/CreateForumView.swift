import SwiftUI

struct CreateForumView: View {
    @State var forumName: String = ""
    @ObservedObject var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Text("Set Forum Name")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding()
            ChatRoomNameTextField(placeholder: "Forum name...", name: $forumName)
            Spacer()
        }
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

// struct CreateForumView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateForumView()
//    }
// }
