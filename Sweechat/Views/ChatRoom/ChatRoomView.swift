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
            ScrollView {
                ScrollViewReader { scrollView in
                    ForEach(viewModel.textMessages, id: \.self) {
                        MessageView(viewModel: $0)
                    }
                    .onAppear { scrollToLatestMessage(scrollView) }
                    .onChange(of: viewModel.textMessages.count) { _ in
                        scrollToLatestMessage(scrollView)
                    }
                    .padding([.leading, .trailing])
                }
            }
            inputBar
        }
        .onAppear { viewModel.initialiseSubscriber() }
        .onDisappear { viewModel.removeSubscriber() }
        .navigationTitle(Text(viewModel.text))
    }

    func scrollToLatestMessage(_ scrollView: ScrollViewProxy) {
        if viewModel.textMessages.isEmpty {
            return
        }
        let index = viewModel.textMessages.count - 1
        scrollView.scrollTo(viewModel.textMessages[index])

    }

    func sendTypedMessage() {
        let content = typingMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            return
        }
        viewModel.handleSendMessage(content)
        typingMessage = ""
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                id: "2",
                name: "Chat Room 2",
                user: User(id: "", name: "", profilePictureUrl: "")
            )
        )
    }
}
