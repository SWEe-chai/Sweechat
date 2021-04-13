import SwiftUI
import os

struct MessagesScrollView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var replyPreviewMetadata: ReplyPreviewMetadata?

    @State private var scrollOffset: CGFloat = .zero
    @State private var heightOffset: CGFloat = .zero
    @State private var canLoadMore: Bool = true

    var body: some View {
        ScrollViewOffset(offset: $scrollOffset, height: $heightOffset) {
            ScrollViewReader { scrollView in
                LazyVStack {
                    if !viewModel.areAllMessagesLoaded {
                        Button(action: viewModel.loadMore) { Text("older messages...") }.padding()
                    }
                    ForEach(viewModel.messages, id: \.self) { messageViewModel in
                        let parentMessage = viewModel.getMessageViewModel(withId: messageViewModel.parentId)
                        MessageView(viewModel: messageViewModel,
                                    parentViewModel: parentMessage, replyPreviewMetadata: $replyPreviewMetadata,
                                    onReplyPreviewTapped: { scrollToMessage(scrollView, parentMessage) })
                    }
                }
                .onAppear { scrollToMessage(scrollView, viewModel.messages.last) }
                .onChange(of: viewModel.messages.count) { _ in
                    handleNewMessages(scrollView)
                }
                .onChange(of: replyPreviewMetadata?.tappedReplyPreview) { _ in
                    handleTappedReplyView(scrollView)
                }
                .padding([.leading, .trailing])
            }
        }
    }

    func handleTappedReplyView(_ scrollView: ScrollViewProxy) {
        guard let metadata = replyPreviewMetadata else {
            os_log("Info: replyPreviewMetadata is nil when detecting change.")
            return
        }

        if metadata.tappedReplyPreview {
            scrollToMessage(scrollView, metadata.messageBeingRepliedTo)
            replyPreviewMetadata?.tappedReplyPreview = false // value-type semantics. change directly
        }
    }

    func handleNewMessages(_ scrollView: ScrollViewProxy) {
        if scrollOffset > heightOffset - UIScreen.main.bounds.height - 300 {
             // in vicinity of the bottom and we get a new message
            scrollToMessage(scrollView, viewModel.messages.last)
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

        if viewModel.messages.contains(message) {
            withAnimation(Animation.easeIn(duration: 1.0)) {
                scrollView.scrollTo(message, anchor: .bottom)
            }
            return
        }

        viewModel.loadUntil(messageViewModel: message)

        checkAsync(interval: 0.1) {
            if viewModel.messages.contains(message) {
                withAnimation(Animation.easeIn(duration: 1.0)) {
                    scrollView.scrollTo(message, anchor: .bottom)
                }
                return false
            }
            return true
        }
    }

    func checkAsync(interval: Double, repeatableFunction: @escaping () -> Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if repeatableFunction() {
                self.checkAsync(interval: interval, repeatableFunction: repeatableFunction)
            }
        }
    }
}

struct MessagesScrollView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesScrollView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   ownerId: "Me",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ), replyPreviewMetadata: Binding.constant(nil)
        )
    }
}
