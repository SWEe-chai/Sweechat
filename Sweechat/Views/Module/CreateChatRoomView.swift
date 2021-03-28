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
    @State var groupName: String = ""

    var body: some View {
        VStack {
//            NavigationLink(
//                destination:
//                    LazyNavView(CreateGroupView(viewModel: viewModel))) {
//                Text("Add Group")
//            }
            if viewModel.currentSelectedMembers.count > 1 {

                HStack {
                    TextField("Group name...", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(5)
                        .frame(idealHeight: 20, maxHeight: 60)
                        .multilineTextAlignment(.leading)
                }
                .frame(idealHeight: 20, maxHeight: 50)
                .padding()
                .background(Color.gray.opacity(0.1))
            }

            Spacer()
//            ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
//                MemberItemView(viewModel: memberItemViewModel)
//                    .onTapGesture {
//                        viewModel.handleCreateChatRoom(name: memberItemViewModel.memberName, isGroup: false)
//                        self.presentationMode.wrappedValue.dismiss()
//                    }
//            }
            ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
                MemberItemView(viewModel: memberItemViewModel)
                    .onTapGesture {
                        viewModel.handleMemberSelection(memberItemViewModel.member)
                    }
            }

        }
        .toolbar {
            Text("Create!!")
                .onTapGesture {
                    viewModel.handleCreateChatRoom(name: groupName)
                    self.presentationMode.wrappedValue.dismiss()
                    self.presentationMode.wrappedValue.dismiss()
                }
        }

    }
}
