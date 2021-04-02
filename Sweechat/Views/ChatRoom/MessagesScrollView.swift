import SwiftUI

struct MessagesScrollView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var messageBeingRepliedTo: MessageViewModel?

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                ForEach(viewModel.messages, id: \.self) { messageViewModel in
                    if let parentMessage = getMessage(withId: messageViewModel.parentId) {
                        // TODO: Make nicer view for the replied message
                        Text("\(parentMessage.previewContent())")
                    }
                    MessageView(viewModel: messageViewModel)
                        // TODO: This will clash with playing of video message
                        .onTapGesture {
                            replyTo(message: messageViewModel)
                        }
                }
                .onAppear { scrollToLatestMessage(scrollView) }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToLatestMessage(scrollView)
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
        messageBeingRepliedTo = message
    }

    private func getMessage(withId id: String?) -> MessageViewModel? {
        viewModel.messages.first {
            $0.id == id
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
