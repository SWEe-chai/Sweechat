//
//  ModuleView.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import SwiftUI

struct ModuleView: View {
    @ObservedObject var viewModel: ModuleViewModel

    var body: some View {
        Text("Create Chat Room")
            .onTapGesture {
                viewModel.handleCreateChatRoom()
            }
        ForEach(viewModel.chatRoomViewModels) { chatRoomViewModel in
            NavigationLink(
                destination:
                    LazyNavView(ChatRoomViewFactory.makeView(
                                    viewModel: chatRoomViewModel))) {
                Text(chatRoomViewModel.text)
            }
        }
        .navigationTitle(Text(viewModel.text))
    }
}
