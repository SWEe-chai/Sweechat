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
                    Button(action: {
                        viewModel.createPrivateGroupChatWith(memberViewModel: memberItemViewModel)
                        isShowing = false
                    }, label: {
                        MemberItemView(viewModel: memberItemViewModel)
                            .padding()
                    })
                    .buttonStyle(PlainButtonStyle())
                    Divider().padding([.leading, .trailing], 20)
                }
                Spacer()
            }
            .background(ColorConstant.base)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Text("New Message")
                .foregroundColor(ColorConstant.dark))
            .toolbar {
                CreateChatRoomToolbarView(viewModel: viewModel, isShowing: $isShowing)
            }
        }
    }
}
