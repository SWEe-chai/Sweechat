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
            HStack {
                Circle()
                    .fill(ColorConstant.placeholder)
                    .frame(width: 70, height: 70)
                Divider()
                    .frame(height: 50, alignment: .center)

                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.text.uppercased())
                            .foregroundColor(.white)
                            .font(FontConstant.ModuleTitle)
                        Spacer()
                    }
                    Text("No module description")
                        .foregroundColor(.white)
                        .font(FontConstant.ModuleDescription)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorConstant.pastel1)
                    .shadow(color: .gray, radius: 5, x: 1, y: 7)
            )
            .padding(.bottom)
        }
    }
}
