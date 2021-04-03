import SwiftUI

struct ThreadView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    var body: some View {
        VStack {
            ForumPostView(viewModel: viewModel.threadViewModel.post)
            ScrollView {
                ForEach(viewModel.threadViewModel.replies, id: \.self) { reply in
                    MessageView(viewModel: reply)
                }
                .padding([.leading, .trailing])
            }
            MessageInputBarView(
                viewModel: viewModel,
                isShowingReply: false,
                replyPreviewMetadata:
                    .constant(
                        ReplyPreviewMetadata(
                            messageBeingRepliedTo: viewModel.threadViewModel.post))
            )
        }
    }
}
