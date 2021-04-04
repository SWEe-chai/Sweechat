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
        HStack {
            ProfilePicture(url: viewModel.profilePictureUrl)
            VStack(alignment: .leading) {
                Text("\(viewModel.text)").font(FontConstant.Heading4)
                Text("Last message...")
                    .font(FontConstant.ModuleDescription)
            }
            .padding(.horizontal)
        }
        .padding()

    }
}
