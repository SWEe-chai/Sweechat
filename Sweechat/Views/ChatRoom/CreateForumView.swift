import SwiftUI

struct CreateForumView: View {
    @State var forumName: String = ""
    @ObservedObject var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            TextField("Group name...", text: $forumName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(5)
                .frame(idealHeight: 20, maxHeight: 60)
                .multilineTextAlignment(.leading)
                .padding()
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
