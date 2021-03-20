import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var id: String

    var body: some View {
        VStack {
            Text(viewModel.text)

            Text("send something")
                .onTapGesture {
                    viewModel.handleSendMessage("hi")
                }

            ScrollView(.vertical) {
                Text("SDFSDF")
                Text("\(viewModel.messageCount)")

                ForEach(viewModel.messages, id: \.self.id) { message in
                    VStack {
                        Text("\(message.content) from \(message.sender.name)")
                    }
                }
            }
        }
    }
}
