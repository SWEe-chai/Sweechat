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

                ForEach(viewModel.textMessages, id: \.self) { message in
                    VStack {
                        Text("\(message)")
                    }
                }
            }
        }
    }
}
