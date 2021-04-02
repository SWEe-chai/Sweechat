//
//  MemberItemView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct MemberItemView: View {
    @ObservedObject var viewModel: MemberItemViewModel

    var body: some View {
        HStack {
            Rectangle()
                .fill(viewModel.isSelected ? Color.green : Color.red)
                .frame(width: 20, height: 20, alignment: .center)
                .cornerRadius(5)

            Text("\(viewModel.memberName)")
        }.onTapGesture {
            viewModel.toggleSelection()
        }
    }
}
