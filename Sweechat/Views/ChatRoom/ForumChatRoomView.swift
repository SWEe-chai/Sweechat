import SwiftUI

struct ForumChatRoomView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    @State var replyPreviewMetadata: ReplyPreviewMetadata?

    var body: some View {
        VStack {
            ForumPostsView(viewModel: viewModel)
            MessageInputBarView(viewModel: viewModel,
                                isShowingReply: false,
                                allowSendMedia: false,
                                replyPreviewMetadata: $replyPreviewMetadata,
                                editedMessageContent: $viewModel.editedMessageContent)
        }.navigationTitle(viewModel.text)
    }
}
