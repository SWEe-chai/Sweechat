//
//  CreateChatRoomView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct CreateChatRoomView: View {
    @ObservedObject var viewModel: ModuleViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            NavigationLink(
                destination:
                    LazyNavView(CreateGroupView(viewModel: viewModel))) {
                Text("Add Group")
            }

            Spacer()
            ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
                MemberItemView(viewModel: memberItemViewModel)
                    .onTapGesture {
                        viewModel.handleCreateChatRoom(name: memberItemViewModel.memberName, isGroup: false)
                        self.presentationMode.wrappedValue.dismiss()
                    }
            }

        }
    }
}
