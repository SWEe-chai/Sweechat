import SwiftUI

struct TextMessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                if let title = viewModel.title {
                    Text(title).font(.footnote)
                }
                if let content = viewModel.content {
                    Text(content)
                        .padding(10)
                        .foregroundColor(viewModel.foregroundColor)
                        .background(viewModel.backgroundColor)
                        .cornerRadius(10)
                }
            }
            if !viewModel.isRightAlign { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TextMessageView_Previews: PreviewProvider {
    static var previews: some View {
        TextMessageView(
            viewModel: MessageViewModel(
                message:
                    Message(
                        id: "",
                        senderId: "",
                        creationTime: Date(),
                        content: "Hello everyone".toData(),
                        type: MessageType.text
                    ),
                sender: User(id: "", name: "One two three"),
                isSenderCurrentUser: true
            )
        )
    }
}
