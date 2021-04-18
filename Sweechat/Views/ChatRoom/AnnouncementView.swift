import SwiftUI

struct AnnouncementView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var parentPreviewMetadata: ParentPreviewMetadata?
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        HStack {
            Spacer()
            MessagesScrollView(
                viewModel: viewModel,
                parentPreviewMetadata: .constant(nil))
            Spacer()
        }
        .onAppear { isNavigationBarHidden = false }
        .background(ColorConstant.base)
        .navigationBarHidden(isNavigationBarHidden)
        .navigationTitle(Text(viewModel.text))
    }
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(
            viewModel:
                ChatRoomViewModel(
                    chatRoom: ChatRoom(
                        id: "chatRoomId",
                        name: "Announcements",
                        ownerId: "Me",
                        currentUser: User(id: "Hello", name: "Happy boi"),
                        currentUserPermission: ChatRoomPermission.all,
                        isStarred: false,
                        creationTime: Date()),
                    user: User(id: "Hello", name: "Happy boi")), isNavigationBarHidden: .constant(false))
    }
}
