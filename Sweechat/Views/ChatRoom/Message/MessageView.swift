//
//  MessageView.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    var parentViewModel: MessageViewModel?
    @Binding var replyPreviewMetadata: ReplyPreviewMetadata?

    // TODO: Change this to delegates in the future
    var onReplyPreviewTapped: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                Text(viewModel.senderName).font(FontConstant.MessageSender)
                if let parent = parentViewModel {
                    ReplyPreviewView(message: parent, borderColor: viewModel.foregroundColor)
                        .onTapGesture {
                            onReplyPreviewTapped?()
                        }
                        .padding(.vertical, 1)
                }
                MessageContentViewFactory.makeView(viewModel: viewModel)
                    .font(FontConstant.MessageText)
                Text("Likes: \(viewModel.likesCount)")
            }
            .padding(10)
            .foregroundColor(viewModel.foregroundColor)
            .background(viewModel.backgroundColor)
            .cornerRadius(10)
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contextMenu {
                contextMenuReplyButton()
                contextMenuLikeButton()
                if viewModel.isRightAlign {
                    if viewModel.isEditable {
                        contextMenuEditButton()
                    }
                    Divider()
                    contextMenuDeleteButton()
                }
            }
            if !viewModel.isRightAlign { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Context Menu Buttons
    private func contextMenuReplyButton() -> some View {
        Button {
            replyTo(message: viewModel)
        } label: {
            Label("Reply", systemImage: "arrowshape.turn.up.left")
        }
    }

    private func contextMenuLikeButton() -> some View {
        Button {
            viewModel.toggleLike()
        } label: {
            Label("Like", systemImage: "hand.thumbsup")
        }
    }

    private func contextMenuEditButton() -> some View {
        Button {
            viewModel.edit()
        } label: {
            Label("Edit", systemImage: "square.and.pencil")
        }
    }

    private func contextMenuDeleteButton() -> some View {
        Button {
            viewModel.delete()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: Context Menu Button functionalities
    private func replyTo(message: MessageViewModel) {
        replyPreviewMetadata = ReplyPreviewMetadata(messageBeingRepliedTo: message)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var message = TextMessageViewModel(message: Message(id: "123",
                                                               senderId: "123",
                                                               creationTime: Date(),
                                                               content: "The message I sent".toData(),
                                                               type: MessageType.text, receiverId: "111",
                                                               parentId: nil, likers: []),
                                              sender: User(id: "123",
                                                           name: "Christine Jane Welly"),
                                              currentUserId: "123")

    static var longMessage = """
    Hello this is a very long message. I hope you are able to bear with me for this one. I am just previewing afterall.
    Yeah man. I hope this gets truncated.
    """

    static var shortMessage = "Message being delivered to"
    static var parent = TextMessageViewModel(message: Message(id: "123",
                                                              senderId: "123",
                                                              creationTime: Date(),
                                                              content: longMessage.toData(),
                                                              type: MessageType.text,
                                                              receiverId: "111",
                                                              parentId: nil, likers: []),
                                             sender: User(id: "123",
                                                          name: "Nguyen Chakra Bai"),
                                             currentUserId: "123")
    static var previews: some View {
        MessageView(viewModel: message, parentViewModel: parent, replyPreviewMetadata: .constant(nil))
    }
}
