import SwiftUI
import os

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
                            .onTapGesture {
                                scrollToMessage(scrollView, parentMessage)
                            }
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

    // TODO: Perhaps combine this with `scrollToLatesMessage`?
    private func scrollToMessage(_ scrollView: ScrollViewProxy, _ message: MessageViewModel) {
        if viewModel.messages.isEmpty {
            os_log("messages are empty")
            return
        }
        guard let index = viewModel.messages.firstIndex(of: message) else {
            os_log("could not find message in the list of messages")
            return
        }
        withAnimation {
            // NOTE: If the message you tapped is already shown on the screen, it won't scroll there
            // Might need to find API that makes the bottom part of the screen scroll to it
            scrollView.scrollTo(viewModel.messages[index])
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
            )
        ) 
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
