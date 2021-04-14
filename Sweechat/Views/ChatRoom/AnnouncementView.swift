import SwiftUI

struct AnnouncementView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var parentPreviewMetadata: ParentPreviewMetadata?

    var body: some View {
        HStack {
            Spacer()
            MessagesScrollView(
                viewModel: viewModel,
                parentPreviewMetadata: .constant(nil))
            Spacer()
        }
        .background(ColorConstant.base)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
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
                        isStarred: false),
                    user: User(id: "Hello", name: "Happy boi")))
    }
}
