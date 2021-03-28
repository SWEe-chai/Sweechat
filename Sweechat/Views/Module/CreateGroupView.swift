//
//  CreateGroupView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct CreateGroupView: View {
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
            NavigationLink(
                destination:
                    LazyNavView(ModuleView(viewModel: viewModel))) {

                Text("Create!!")
            }
        }
    }
}
