//
//  ChatRoomItemView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct ChatRoomItemView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfilePicture(url: viewModel.profilePictureUrl)
                VStack(alignment: .leading) {
                    Text("\(viewModel.text)")
                        .font(FontConstant.Heading4)
                        .foregroundColor(ColorConstant.dark)
                        .lineLimit(1)
                    HStack {
                        Text(viewModel.latestMessagePreview)
                            .font(FontConstant.ChatRoomDescription)
                            .foregroundColor(ColorConstant.dark)
                            .lineLimit(1)
                            .padding(.trailing)
                        Spacer()
                        Text(viewModel.lastestMessageTime?.timeAgoDisplay() ?? "")
                            .font(FontConstant.Description)
                            .foregroundColor(ColorConstant.dark)
                            .lineLimit(1)
                    }
                }
                .padding(.leading)
            }
            .contentShape(Rectangle())
            .padding()
            .padding(.horizontal)
        }
    }
}
