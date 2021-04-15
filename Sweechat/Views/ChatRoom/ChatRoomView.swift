import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var replyPreviewMetadata: ReplyPreviewMetadata?
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel,
                               replyPreviewMetadata: $replyPreviewMetadata)
            MessageInputBarView(viewModel: viewModel,
                                isShowingReply: true,
                                replyPreviewMetadata: $replyPreviewMetadata)
        }
        .onAppear {
            viewModel.handleChatRoomAppearance()
            isNavigationBarHidden = false
        }
        .navigationBarHidden(isNavigationBarHidden)
        .background(ColorConstant.base)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .navigationTitle(Text(viewModel.text))
    }
}

struct ReplyPreviewMetadata {
    var messageBeingRepliedTo: MessageViewModel
    var tappedReplyPreview: Bool = false
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   ownerId: "Me",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ), isNavigationBarHidden: Binding<Bool>(
                get: { true },
                set: { _ in }
            )
        )
    }
}

enum ModalView {
    case MediaPicker
    case Canvas
}
