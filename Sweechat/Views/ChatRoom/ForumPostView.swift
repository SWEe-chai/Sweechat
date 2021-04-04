import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            MessageContentViewFactory.makeView(viewModel: viewModel)
            HStack {
                Spacer()
                Text(viewModel.senderName)
                    .font(FontConstant.MessageSender)
            }
        }
        .padding(10)
        .background(ColorConstant.dark)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
