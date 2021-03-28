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
        VStack {
            NavigationLink(
                destination:
                    LazyNavView(CreateGroupView(viewModel: viewModel))) {
                Text("Add Group")
            }

            Spacer()
            ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
                let chatRoom = ChatRoom(
                    name: memberItemViewModel.memberName,
                    members: [viewModel.user, memberItemViewModel.member]
                )
                MemberItemView(viewModel: memberItemViewModel)
                    .onTapGesture {
                        viewModel.handleCreateChatRoom(chatRoom: chatRoom)
                    }
                NavigationLink(
                    "",
                    destination: LazyNavView(
                        ModuleView(viewModel: viewModel)
                    ),
                    isActive: $viewModel.isChatRoomSelected
                )
                .hidden()
            }

        }
    }
}
