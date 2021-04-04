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
                .fill(viewModel.isSelected ? Color.blue : Color(white: 0, opacity: 0))
                .frame(width: 20, height: 20, alignment: .center)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(white: 0, opacity: 0.5), lineWidth: 1)
                )
            Text("\(viewModel.memberName)").padding(.leading, 10)
            Spacer()
        }
        .padding()
        .border(width: 1,
                edges: [.bottom],
                color: Color(white: 0, opacity: 0.1))
        .onTapGesture {
            viewModel.toggleSelection()
        }
    }
}
