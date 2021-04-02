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
                VStack {
                    ReplyPreviewView()
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
    var body: some View {
        VStack {
            Text("Sender")
                .fontWeight(.bold)
            Text("Asdf")
        }
        .font(.caption)
    }
 }

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(viewModel:
                        MessageViewModel(message: Message(id: "123",
                                                          senderId: "123",
                                                          creationTime: Date(),
                                                          content: "Data".toData(),
                                                          type: MessageType.text,
                                                          parentId: nil),
                                         sender: User(id: "123"),
                                         isSenderCurrentUser: false))
    }
}
