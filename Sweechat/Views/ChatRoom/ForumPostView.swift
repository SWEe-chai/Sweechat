import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: ThreadChatRoomViewModel
    var clickable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    MessageContentViewFactory.makeView(viewModel: viewModel.post)
                        .foregroundColor(ColorConstant.base)
                        .font(FontConstant.ForumPost)
                    HStack {
                        ProfilePicture(url: viewModel.post.profilePictureUrl)
                        Text(viewModel.post.senderName)
                            .font(FontConstant.MessageSender)
                            .foregroundColor(ColorConstant.base)
                        Spacer()
                        LikeButtonView(viewModel: viewModel.post)
                            .foregroundColor(ColorConstant.base)
                            .padding(.leading)
                    }
                }
                Spacer()
                if clickable {
                    Image(systemName: "chevron.right")
                        .foregroundColor(ColorConstant.light)
                        .padding(.leading)
                }
            }.padding(.leading).padding(.top, 5)
            Divider()
                .background(ColorConstant.white)
            if let mostPopularMessage = viewModel.mostPopularMessage, clickable {
                HStack {
                    Spacer()
                    MostPopularThreadMessageView(viewModel: mostPopularMessage)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
        .background(ColorConstant.dark)
        .contextMenu {
            if viewModel.post.isSenderCurrentUser {
                contextMenuDeleteButton()
            }
        }
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }

    private func contextMenuDeleteButton() -> some View {
        Button {
            viewModel.post.delete()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
