import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""

    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        UIListContentView.appearance()
        UITableView.appearance().tableFooterView = UIView()
    }

    var body: some View {
        VStack {
            Text(viewModel.text)
            List {
                ForEach(viewModel.textMessages) {
                    MessageView(viewModel: $0)
                }
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
