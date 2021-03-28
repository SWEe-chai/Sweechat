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
        VStack {
            NavigationLink(
                destination:
                    LazyNavView(CreateChatRoomView(viewModel: viewModel))) {

                Text("Create Chat Room")
            }
            Text("Chatrooms in \(viewModel.text)")
            ForEach(viewModel.chatRoomViewModels) { chatRoomViewModel in
                NavigationLink(
                    destination:
                        LazyNavView(ChatRoomView(viewModel: chatRoomViewModel))) {
                    ChatRoomItemView(viewModel: chatRoomViewModel)
                }
            }
        }
        .navigationTitle(Text(viewModel.text))
    }
}
