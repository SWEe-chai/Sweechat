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
                MessageContentViewFactory.makeView(viewModel: viewModel)
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
