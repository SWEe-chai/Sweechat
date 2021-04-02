import SwiftUI

struct AnnouncementView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var messageBeingRepliedTo: MessageViewModel?
    @State var tappedReplyPreviewFromInputBar = false
    var body: some View {
        // TODO: Added messageBeingRepliedTo because of changes in MessagesScrollView. Change view in
        // the future
        MessagesScrollView(viewModel: viewModel,
                           messageBeingRepliedTo: $messageBeingRepliedTo,
                           tappedReplyPreviewFromInputBar: $tappedReplyPreviewFromInputBar)
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
                        currentUser: User(id: "Hello", name: "Happy boi"),
                        currentUserPermission: ChatRoomPermission.all),
                    user: User(id: "Hello", name: "Happy boi")))
    }
}
