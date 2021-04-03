import SwiftUI

struct ForumChatRoomView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    @State var messageBeingRepliedTo: MessageViewModel?
    @State var replyPreviewMetadata: ReplyPreviewMetadata?

    var body: some View {
        MessagesScrollView(viewModel: viewModel,
                           replyPreviewMetadata: $replyPreviewMetadata)
        MessageInputBarView(viewModel: viewModel,
                            replyPreviewMetadata: $replyPreviewMetadata)
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
