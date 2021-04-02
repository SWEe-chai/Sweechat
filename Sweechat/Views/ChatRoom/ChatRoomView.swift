import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var messageBeingRepliedTo: MessageViewModel?

    // TODO: Starting to pass a lot of variables.. Not sure what better way there is
    @State var tappedReplyPreviewFromInputBar: Bool = false

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel,
                               messageBeingRepliedTo: $messageBeingRepliedTo,
                               tappedReplyPreviewFromInputBar: $tappedReplyPreviewFromInputBar)
            MessageInputBarView(viewModel: viewModel,
                                messageBeingRepliedTo: $messageBeingRepliedTo,
                                tappedReplyPreviewFromInputBar: $tappedReplyPreviewFromInputBar)
        }
        .navigationTitle(Text(viewModel.text))
    }

}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ), tappedReplyPreviewFromInputBar: false
        )
    }
}

enum ModalView {
    case MediaPicker
    case Canvas
}
