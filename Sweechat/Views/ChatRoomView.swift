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
                Text("\(self.viewModel.chatRoom.messages.count)")

                ForEach(viewModel.chatRoom.messages, id: \.self.id) { message in
                    Text("WHY THE NANI IS NOT HERE")
                    VStack {
                        Text("\(message.content) from \(message.sender.name)")
                    }
                }
            }
        }
    }
}
