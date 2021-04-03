//
//  ModuleItemView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 3/4/21.
//
import SwiftUI
// This is added so that the list item updates when the module updates
struct ModuleItemView: View {
    @ObservedObject var viewModel: ModuleViewModel
    var body: some View {
        NavigationLink(
            destination:
                LazyNavView(ModuleView(viewModel: viewModel))) {
            VStack {
                HStack {
                    Text(viewModel.text.uppercased())
                        .foregroundColor(.white)
                        .font(FontConstant.font1)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorConstant.pastel1)
                        .shadow(color: .gray, radius: 5, x: 1, y: 7)
                )
                .padding()
                .padding(.horizontal)
            }
        }
    }
}
