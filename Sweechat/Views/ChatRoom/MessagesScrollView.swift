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
                                    onReplyPreviewTapped: { scrollToMessage(scrollView, parentMessage, anchor: .top) })
                    }
                }
                .onAppear { scrollToMessage(scrollView, viewModel.messages.last, anchor: .bottom) }
                .onChange(of: viewModel.latestMessageViewModel) { _ in
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
            scrollToMessage(scrollView, metadata.messageBeingRepliedTo, anchor: .top)
            replyPreviewMetadata?.tappedReplyPreview = false // value-type semantics. change directly
        }
    }

    func handleNewMessages(_ scrollView: ScrollViewProxy) {
        if scrollOffset > heightOffset - UIScreen.main.bounds.height - 300 {
             // in vicinity of the bottom and we get a new message
            scrollToMessage(scrollView, viewModel.messages.last, anchor: .bottom)
        }
    }

    // TODO: Perhaps combine this with `scrollToLatesMessage`?
    private func scrollToMessage(_ scrollView: ScrollViewProxy,
                                 _ message: MessageViewModel?,
                                 anchor: UnitPoint) {
        os_log("Scrolling to \(message?.id ?? "nil message")")

        if viewModel.messages.isEmpty {
            os_log("messages are empty")
            return
        }
        guard let message = message else {
            os_log("nil MessageViewModel passed into scrollToMessage")
            return
        }

        if viewModel.messages.contains(message) {
            scrollView.scrollTo(message, anchor: anchor)
            return
        }

        viewModel.loadUntil(messageViewModel: message)

        checkAsync(interval: 0.1) {
            if viewModel.messages.contains(message) {
                withAnimation(Animation.easeIn(duration: 0.5)) {
                    scrollView.scrollTo(message, anchor: anchor)
                }
                return false
            }
            return true
        }
    }

    func checkAsync(interval: Double,
                    repeatableFunction: @escaping () -> Bool,
                    timeToLive: Int = 15) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if timeToLive <= 0 {
                os_log("Check async function ran total time to live and terminated")
                return
            }
            if repeatableFunction() {
                self.checkAsync(interval: interval, repeatableFunction: repeatableFunction, timeToLive: timeToLive - 1)
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
                                   currentUserPermission: ChatRoomPermission.readWrite,
                                   isStarred: false),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ), replyPreviewMetadata: Binding.constant(nil)
        )
    }
}
