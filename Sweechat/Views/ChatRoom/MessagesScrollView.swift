import SwiftUI
import os

struct MessagesScrollView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var replyPreviewMetadata: ReplyPreviewMetadata?

    @State private var scrollOffset: CGFloat = .zero
    @State private var heightOffset: CGFloat = .zero
    @State private var canLoadMore: Bool = true

    var body: some View {
        // Please becareful changing this view, everything is flipped
        ScrollViewOffset(offset: $scrollOffset, height: $heightOffset) {
            ScrollViewReader { scrollView in
                LazyVStack {
                    ForEach(viewModel.messages, id: \.self) { messageViewModel in
                        let parentMessage = getMessage(withId: messageViewModel.parentId)
                        MessageView(viewModel: messageViewModel,
                                    parentViewModel: parentMessage, replyPreviewMetadata: $replyPreviewMetadata,
                                    onReplyPreviewTapped: { scrollToMessage(scrollView, parentMessage) }).flip()
                    }
                }
                .onAppear { scrollToLatestMessage(scrollView) }
                .onChange(of: viewModel.messages.count) { _ in
                    handleNewMessages(scrollView)
                }
                .onChange(of: scrollOffset) { handleOffsetChange(offset: $0) }
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
        }.flip()
    }

    func handleNewMessages(_ scrollView: ScrollViewProxy) {
        if scrollOffset <= 300 {
            // in vicinity of the bottom and we get a new message
            scrollToLatestMessage(scrollView)
        }
    }

    func handleOffsetChange(offset: CGFloat) {
        if scrollOffset / abs(heightOffset - UIScreen.main.bounds.size.height) >= 0.7 && canLoadMore {
            viewModel.loadMore()
            self.canLoadMore = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.canLoadMore = true
            }
        }
    }

    func scrollToLatestMessage(_ scrollView: ScrollViewProxy) {
        if viewModel.messages.count <= 1 {
            return
        }
        scrollView.scrollTo(viewModel.messages[0])
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
        withAnimation(Animation.easeIn(duration: 1.0)) {
            scrollView.scrollTo(viewModel.messages[index], anchor: .bottom)
        }
    }
}

extension View {
    public func flip() -> some View {
        self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
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
