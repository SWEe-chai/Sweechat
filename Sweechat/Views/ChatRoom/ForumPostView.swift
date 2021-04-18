import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: ThreadChatRoomViewModel
    var clickable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            MessageContentViewFactory.makeView(viewModel: viewModel.post)
                                .foregroundColor(ColorConstant.dark)
                                .font(FontConstant.ForumPost)

                        }.padding(.leading)
                            .overlay(
                                Rectangle()
                                    .fill(ColorConstant.primary)
                                    .frame(width: 4)
                                    .padding(.trailing),
                                alignment: .leading
                            )

                        Spacer()
                        if clickable {
                            Image(systemName: "chevron.right")
                                .foregroundColor(ColorConstant.dark)
                                .padding()
                        }
                    }

                    HStack {
                        ProfilePicture(url: viewModel.post.profilePictureUrl, size: 25)
                        Text(viewModel.post.senderName)
                            .font(FontConstant.MessageSender)
                            .foregroundColor(ColorConstant.tertiary)
                        Spacer()
                        LikeButtonView(viewModel: viewModel.post)
                            .foregroundColor(ColorConstant.tertiary)
                            .padding(.horizontal)
                    }
                }
            }.padding(.leading).padding(.top, 5)
            Divider()
                .background(ColorConstant.primary)
            if let mostPopularMessage = viewModel.mostPopularMessage, clickable {
                HStack {
                    Spacer()
                    MostPopularThreadMessageView(viewModel: mostPopularMessage)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
        .background(ColorConstant.tertiary2)
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
