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
                    }.padding()
                }
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Message")
            .toolbar {
                NavigationLink("Group Chat",
                               destination:
                                LazyNavView(
                                    ChooseGroupChatMembersView(
                                        viewModel: viewModel,
                                        isShowing: $isShowing)))
            }
        }
    }
}
