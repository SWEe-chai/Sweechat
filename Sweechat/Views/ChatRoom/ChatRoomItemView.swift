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
                    Text("Last message...")
                        .font(FontConstant.Description)
                        .foregroundColor(ColorConstant.dark)
                }
                .padding(.horizontal)
            }
            .padding()
            .padding(.horizontal)
        }
    }
}
