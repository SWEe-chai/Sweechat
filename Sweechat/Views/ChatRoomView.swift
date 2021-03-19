import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var id: String

    var body: some View {
        VStack {
            Text(viewModel.text)
                .onAppear {
                    viewModel.connectToFirebase(chatRoomId: id)
                }

            Text("send something")
                .onTapGesture {
                    viewModel.handleSendMessage("hi")
                }

            ScrollView(.vertical) {

                ForEach(viewModel.chatRoom.messages, id: \.self.id) { message in
                    VStack {
                        if message.sender.id == AppConstant.user.id {
                            Text("\(message.sender.name): \(message.content)")
                                .foregroundColor(Color.green)
                        } else {
                            Text("\(message.sender.name): \(message.content)")
                                .foregroundColor(Color.red)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
