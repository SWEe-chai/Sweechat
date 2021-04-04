//
//  MessageView.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import SwiftUI

struct MessageView: View {
    var viewModel: MessageViewModel
    var parentViewModel: MessageViewModel?

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
            }
            .padding(10)
            .foregroundColor(viewModel.foregroundColor)
            .background(viewModel.backgroundColor)
            .cornerRadius(10)
            if !viewModel.isRightAlign { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var message = TextMessageViewModel(message: Message(id: "123",
                                                               senderId: "123",
                                                               creationTime: Date(),
                                                               content: "The message I sent".toData(),
                                                               type: MessageType.text, receiverId: "111",
                                                               parentId: nil),
                                              sender: User(id: "123",
                                                           name: "Christine Jane Welly"),
                                              isSenderCurrentUser: false)

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
                                                              parentId: nil),
                                             sender: User(id: "123",
                                                          name: "Nguyen Chakra Bai"),
                                             isSenderCurrentUser: false)
    static var previews: some View {
        MessageView(viewModel: message, parentViewModel: parent)
    }
}
