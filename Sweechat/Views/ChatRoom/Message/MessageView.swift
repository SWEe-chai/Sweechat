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

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                if let title = viewModel.title {
                    Text(title).font(.footnote)
                }
                VStack(alignment: .leading) {
                    if let parent = parentViewModel {
                        ReplyPreviewView(message: parent)
                    }
                    MessageContentViewFactory.makeView(viewModel: viewModel)
                }
                .padding(10)
                .foregroundColor(viewModel.foregroundColor)
                .background(viewModel.backgroundColor)
                .cornerRadius(10)

            }
            if !viewModel.isRightAlign { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
}

 struct ReplyPreviewView: View {
    var message: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(message.senderName)
                .fontWeight(.bold)
            Text(message.previewContent())
                .lineLimit(1)
        }
        .padding(.leading, 10)
        .font(.caption)
        .border(width: 2, edges: [.leading], color: Color.gray)
        // So that it does not stretch vertically
        .fixedSize(horizontal: false, vertical: true)
    }
 }

struct MessageView_Previews: PreviewProvider {
    static var message = TextMessageViewModel(message: Message(id: "123",
                                                               senderId: "123",
                                                               creationTime: Date(),
                                                               content: "The message I sent".toData(),
                                                               type: MessageType.text,
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
                                                              parentId: nil),
                                             sender: User(id: "123",
                                                          name: "Nguyen Chakra Bai"),
                                             isSenderCurrentUser: false)
    static var previews: some View {
        MessageView(viewModel: message, parentViewModel: parent)
    }
}
