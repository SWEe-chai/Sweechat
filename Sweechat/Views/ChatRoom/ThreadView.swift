import SwiftUI

struct ThreadView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    var body: some View {
        VStack {
            ForumPostView(viewModel: viewModel.threadViewModel.post)
            ScrollView {
                ScrollViewReader { scrollView in
                    ForEach(viewModel.threadViewModel.replies, id: \.self) { reply in
                        MessageView(viewModel: reply)
                    }
                    .onAppear { scrollToLatestMessage(scrollView) }
                    .onChange(of: viewModel.threadViewModel.replies.count) { _ in
                        scrollToLatestMessage(scrollView)
                    }
                    .padding([.leading, .trailing])
                }
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
    func scrollToLatestMessage(_ scrollView: ScrollViewProxy) {
        if viewModel.threadViewModel.replies.isEmpty {
            return
        }
        let index = viewModel.threadViewModel.replies.count - 1
        scrollView.scrollTo(viewModel.threadViewModel.replies[index])
    }
}
