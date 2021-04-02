import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var messageBeingRepliedTo: MessageViewModel?

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel, messageBeingRepliedTo: $messageBeingRepliedTo)
            MessageInputBarView(viewModel: viewModel, messageBeingRepliedTo: $messageBeingRepliedTo)
        }
        .navigationTitle(Text(viewModel.text))
    }

}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
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

enum ModalView {
    case MediaPicker
    case Canvas
}
