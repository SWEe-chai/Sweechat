import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            MessageContentViewFactory.makeView(viewModel: viewModel)
                .font(FontConstant.ForumPost)
                .foregroundColor(ColorConstant.white)
            HStack {
                Spacer()
                Text(viewModel.senderName)
                    .font(FontConstant.MessageSender)
                    .foregroundColor(ColorConstant.white)
            }
        }
        .padding(10)
        .background(ColorConstant.dark)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
