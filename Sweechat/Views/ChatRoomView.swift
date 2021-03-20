import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""

    var inputBar: some View {
        HStack {
            TextEditor(text: $typingMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(5)
                .frame(idealHeight: 20, maxHeight: 60)
                .multilineTextAlignment(.leading)
            Button(action: sendTypedMessage) {
                Text("Send")
            }
        }
        .frame(idealHeight: 20, maxHeight: 50)
        .padding()
        .background(Color.gray.opacity(0.1))
    }

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
            inputBar
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
