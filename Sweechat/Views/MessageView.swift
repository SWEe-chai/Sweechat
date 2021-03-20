//
//  MessageView.swift
//  Sweechat
//
//  Created by Hai Nguyen on 20/3/21.
//

import SwiftUI

struct MessageView: View {
    var viewModel: MessageViewModel
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                Text(viewModel.title).font(.footnote)
                Text(viewModel.content)
                    .padding(10)
                    .foregroundColor(viewModel.foregroundColor)
                    .background(viewModel.backgroundColor)
                    .cornerRadius(10)
            }
            if !viewModel.isRightAlign { Spacer() }
        }.frame(maxWidth: .infinity)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(
            viewModel: MessageViewModel(
                message: Message(id: "",
                                 sender: User(details: UserRepresentation(id: "", name: "", profilePictureUrl: "")),
                                 creationTime: Date(),
                                 content: "Hello everyone"),
                isCurrentUser: true))
    }
}
