import SwiftUI

struct AnnouncementView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var body: some View {
        MessagesScrollView(viewModel: viewModel)
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
                        currentUserPermission: ChatRoomPermission.all),
                    user: User(id: "Hello", name: "Happy boi")))
    }
}
