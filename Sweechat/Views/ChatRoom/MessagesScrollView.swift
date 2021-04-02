import SwiftUI

struct MessagesScrollView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                ForEach(viewModel.messages, id: \.self) {
                    MessageView(viewModel: $0)
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
}

struct MessagesScrollView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesScrollView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            )
        )
    }
}
