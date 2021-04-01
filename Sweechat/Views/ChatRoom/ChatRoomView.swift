import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel)
            MessageInputBarView(viewModel: viewModel)
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
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   permissions: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            )
        )
    }
}
