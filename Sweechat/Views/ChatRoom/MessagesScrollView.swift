import SwiftUI
import os

struct MessagesScrollView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var replyPreviewMetadata: ReplyPreviewMetadata?

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                ForEach(viewModel.messages, id: \.self) { messageViewModel in
                    let parentMessage = getMessage(withId: messageViewModel.parentId)
                    MessageView(viewModel: messageViewModel,
                                parentViewModel: parentMessage,
                                onReplyPreviewTapped: { scrollToMessage(scrollView, parentMessage) })
                        // TODO: On VideoMessage, it might be hard to tap because the player takes precendence
                        .onTapGesture(count: 2) {
                            replyTo(message: messageViewModel)
                        }
                }
                .onAppear { scrollToLatestMessage(scrollView) }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToLatestMessage(scrollView)
                }
                .onChange(of: replyPreviewMetadata?.tappedReplyPreview) { _ in
                    guard let metadata = replyPreviewMetadata else {
                        os_log("Info: replyPreviewMetadata is nil when detecting change.")
                        return
                    }

                    if metadata.tappedReplyPreview {
                        scrollToMessage(scrollView, metadata.messageBeingRepliedTo)
                        replyPreviewMetadata?.tappedReplyPreview = false // value-type semantics. change directly
                    }
                }
                .padding([.leading, .trailing])
            }
        }
    }

    func scrollToLatestMessage(_ scrollView: ScrollViewProxy) {
        if viewModel.messages.isEmpty {
            return
        }
        let index = viewModel.messages.count - 1
        scrollView.scrollTo(viewModel.messages[index])

    }

    private func replyTo(message: MessageViewModel) {
        replyPreviewMetadata = ReplyPreviewMetadata(messageBeingRepliedTo: message)
    }

    private func getMessage(withId id: String?) -> MessageViewModel? {
        viewModel.messages.first {
            $0.id == id
        }
    }

    // TODO: Perhaps combine this with `scrollToLatesMessage`?
    private func scrollToMessage(_ scrollView: ScrollViewProxy, _ message: MessageViewModel?) {
        if viewModel.messages.isEmpty {
            os_log("messages are empty")
            return
        }
        guard let message = message else {
            os_log("nil MessageViewModel passed into scrollToMessage")
            return
        }
        guard let index = viewModel.messages.firstIndex(of: message) else {
            os_log("could not find message in the list of messages")
            return
        }
        withAnimation {
            // TODO: If we are scrolling to the bottom few messages, the entire ScrollView will
            // keep moving up and ending with half the bottom view being white (i.e. empty spaces are
            // pushed up)
            // i.e. try replying to the bottommost message, and tapping that reply
            scrollView.scrollTo(viewModel.messages[index], anchor: .center)
        }
    }
}

// TODO: Currently removed because it is complaining due to the messageBeingRepliedTo
// struct MessagesScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagesScrollView(
//            viewModel: ChatRoomViewModel(
//                chatRoom: ChatRoom(id: "0",
//                                   name: "CS4269",
//                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
//                                   currentUserPermission: ChatRoomPermission.readWrite),
//                user: User(id: "", name: "Hello", profilePictureUrl: "")
//            )
//        )
//    }
// }
