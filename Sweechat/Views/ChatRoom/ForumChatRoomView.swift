import SwiftUI

struct ForumChatRoomView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    @State var replyPreviewMetadata: ReplyPreviewMetadata?

    var body: some View {
        VStack {
            ForumPostsView(viewModel: viewModel)
            MessageInputBarView(viewModel: viewModel,
                                isShowingReply: false,
                                replyPreviewMetadata: $replyPreviewMetadata)
        }.navigationTitle(viewModel.text)
    }
}

struct ForumChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ForumChatRoomView(
            viewModel:
                ForumChatRoomViewModel(
                    forumChatRoom: ForumChatRoom(
                        name: "Forum",
                        members: [User(id: "1", name: "Hello"), User(id: "2", name: "Hi")],
                        currentUser: User(id: "1", name: "Hello"))))
    }
}
