//
//  CreateGroupView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ModuleViewModel
    @State var groupName: String = ""
    var body: some View {
        VStack {
            HStack {
                TextEditor(text: $groupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(5)
                    .frame(idealHeight: 20, maxHeight: 60)
                    .multilineTextAlignment(.leading)
            }
            .frame(idealHeight: 20, maxHeight: 50)
            .padding()
            .background(Color.gray.opacity(0.1))

            Spacer()
            ForEach(viewModel.otherMembersItemViewModels) { memberItemViewModel in
                MemberItemView(viewModel: memberItemViewModel)
                    .onTapGesture {
                        memberItemViewModel.toggleSelection()
                    }
            }
        }
        .toolbar {
            Text("Create!!")
                .onTapGesture {
                    viewModel.handleCreateChatRoom(name: groupName, isGroup: true)
                    self.presentationMode.wrappedValue.dismiss()
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
    }
}
