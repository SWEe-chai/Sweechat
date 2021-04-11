import SwiftUI

struct ThreadView: View {
    @ObservedObject var viewModel: ThreadChatRoomViewModel
    @State var replyPreviewMetadata: ReplyPreviewMetadata?
    var body: some View {
        VStack {
            ForumPostView(viewModel: viewModel.post).padding()
            MessagesScrollView(viewModel: viewModel,
                               replyPreviewMetadata: $replyPreviewMetadata)
            MessageInputBarView(viewModel: viewModel,
                                isShowingReply: true,
                                replyPreviewMetadata: $replyPreviewMetadata,
                                editedMessageContent: $viewModel.editedMessageContent)
        }.background(ColorConstant.base)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .navigationTitle(Text("Thread"))
    }
}
