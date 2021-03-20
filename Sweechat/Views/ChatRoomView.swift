import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: viewModel.didTapBackButton) {
                        Text("Back")
                    }
                    .padding()
                    Spacer()
                }
                Text(viewModel.text)
            }
            ScrollView {
                ForEach(viewModel.textMessages) {
                    MessageView(viewModel: $0)
                }
                .padding([.leading, .trailing])
            }
            HStack {
                TextField("Message...", text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                Button(action: sendTypedMessage) {
                    Text("Send")
                }
            }.frame(minHeight: 20).padding()
        }
    }

    func sendTypedMessage() {
        if typingMessage.isEmpty {
            return
        }
        viewModel.handleSendMessage(typingMessage)
        typingMessage = ""
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                id: "2",
                user: User(
                    details: UserRepresentation(id: "", name: "", profilePictureUrl: ""))))
    }
}
