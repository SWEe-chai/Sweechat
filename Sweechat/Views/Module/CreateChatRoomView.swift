//
//  CreateChatRoomView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct CreateChatRoomView: View {
    var viewModel: CreateChatRoomViewModel
    @Binding var isShowing: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ForEach(viewModel.otherUsersViewModels) { memberItemViewModel in
                    Button(memberItemViewModel.memberName) {
                        viewModel.createPrivateGroupChatWith(
                            memberViewModel: memberItemViewModel)
                        isShowing = false
                    }.padding()
                }
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Message")
            .toolbar {
                HStack {
                    NavigationLink("Group",
                                   destination:
                                    LazyNavView(
                                        ChooseGroupChatMembersView(
                                            viewModel: viewModel,
                                            viewAfterChoosingMembers:
                                                AnyView(LazyNavView(CreateGroupChatView(
                                                                viewModel: viewModel,
                                                                isShowing: $isShowing))),
                                            isShowing: $isShowing)))
                    NavigationLink("Forum",
                                   destination:
                                    LazyNavView(
                                        ChooseGroupChatMembersView(
                                            viewModel: viewModel,
                                            viewAfterChoosingMembers:
                                                AnyView(LazyNavView(CreateForumView(
                                                                        viewModel: viewModel,
                                                                        isShowing: $isShowing))),
                                            isShowing: $isShowing)))
                }
            }
        }
    }
}
