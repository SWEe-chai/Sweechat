import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var id: String

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapBackButton) {
                Text("Back")
            }
            .foregroundColor(.red)

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
