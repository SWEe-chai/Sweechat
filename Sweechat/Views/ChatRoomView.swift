import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var id: String

    var body: some View {
        Text(viewModel.text)
            .onAppear {
                viewModel.connectToFirebase(chatRoomId: id)
            }
    }
}
