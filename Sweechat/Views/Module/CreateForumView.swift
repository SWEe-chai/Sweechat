import SwiftUI

struct CreateForumView: View {
    @State var forumName: String = ""
    @ObservedObject var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            ChatRoomNameTextField(placeholder: "Forum name...", name: $forumName)
            Spacer()
        }
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
