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
    var index: Int
    var body: some View {
        NavigationLink(
            destination:
                LazyNavView(ModuleView(viewModel: viewModel))) {
            HStack {
                Circle()
                    .fill(ColorConstant.placeholder)
                    .frame(width: 70, height: 70)

                Divider()
                    .padding(.leading, 7)
                    .padding(.trailing, 7)
                    .foregroundColor(ColorConstant.dark)
                    .frame(height: 50, alignment: .center)

                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.text)
                            .lineLimit(1)
                            .foregroundColor(Color.white)
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
                    .fill(ColorConstant.primary)
                    .shadow(color: .gray, radius: 5, x: 1, y: 7)
            )
            .padding(.bottom)
        }
    }
}
