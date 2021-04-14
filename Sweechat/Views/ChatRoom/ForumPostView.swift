import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: ThreadChatRoomViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfilePicture(url: viewModel.post.profilePictureUrl)
                Text(viewModel.post.senderName)
                    .font(FontConstant.MessageSender)
                    .foregroundColor(ColorConstant.white)
                Spacer()
                LikeButtonView(viewModel: viewModel.post)
                    .foregroundColor(ColorConstant.white)
            }
            Divider()
                .background(ColorConstant.white)
            MessageContentViewFactory.makeView(viewModel: viewModel.post)
                .font(FontConstant.ForumPost)
                .foregroundColor(ColorConstant.white)
            if let mostPopularMessage = viewModel.mostPopularMessage {
                HStack {
                    Spacer()
                    MostPopularThreadMessageView(viewModel: mostPopularMessage)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
        .background(ColorConstant.dark)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
