//
//  MessageView.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import SwiftUI

struct MessageView: View {
    var viewModel: MessageViewModel
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                if let title = viewModel.title {
                    Text(title).font(.footnote)
                }
                VStack(alignment: .leading) {
                    ReplyPreviewView(message: viewModel)
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
        HStack {
            // custom vertical divider
            Rectangle().fill(Color.gray).frame(width: 2)
            VStack(alignment: .leading) {
                Text(message.senderName)
                    .fontWeight(.bold)
                Text(message.previewContent())
            }
            .font(.caption)
        }
        // So that it does not stretch vertically
        .fixedSize(horizontal: false, vertical: true)
    }
 }

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(viewModel:
                        TextMessageViewModel(message: Message(id: "123",
                                                              senderId: "123",
                                                              creationTime: Date(),
                                                              content: "Message being replied to!".toData(),
                                                              type: MessageType.text,
                                                              parentId: nil),
                                         sender: User(id: "123",
                                                      name: "Christine Jane Welly"),
                                         isSenderCurrentUser: false))
    }
}
