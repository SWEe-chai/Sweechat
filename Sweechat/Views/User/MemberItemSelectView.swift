//
//  MemberItemView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct MemberItemSelectView: View {
    @ObservedObject var viewModel: MemberItemViewModel

    var body: some View {
        HStack {
            Rectangle()
                .fill(viewModel.isSelected ? ColorConstant.primary : Color(white: 0, opacity: 0))
                .frame(width: 20, height: 20, alignment: .center)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(white: 0, opacity: 0.5), lineWidth: 1))
            MemberItemView(viewModel: viewModel)
            Spacer()
        }
        .onTapGesture {
            viewModel.toggleSelection()
        }
    }
}

struct MemberItemSelectView_Previews: PreviewProvider {
    static var previews: some View {
        MemberItemSelectView(
            viewModel:
                MemberItemViewModel(
                    member:
                        User(
                            id: "1",
                            name: "Hai Nguyen",
                            profilePictureUrl: """
                                        https://lh3.googleusercontent.com/
                                        a-/AOh14Gh7yXK1BE34ZK09UVtZHy_lGrGaqbUP2VGMmxsHzw=s96-c
                                        """)))
    }
}
