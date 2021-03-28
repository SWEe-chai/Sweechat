//
//  CreateChatRoomView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct CreateChatRoomView: View {
    @ObservedObject var viewModel: ModuleViewModel

    var body: some View {
        ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
            let chatRoomViewModel = ChatRoomViewModel(
                chatRoom: ChatRoom(
                    name: memberItemViewModel.memberName,
                    members: [viewModel.user, memberItemViewModel.member]
                ),
                user: viewModel.user
            )
            NavigationLink(
                destination:
                    LazyNavView(ChatRoomView(viewModel: chatRoomViewModel))) {
                MemberItemView(viewModel: memberItemViewModel)
            }
        }

        .onTapGesture {
            viewModel.handleCreateChatRoom()
        }

    }
}
