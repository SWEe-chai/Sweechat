//
//  HomeToolbarView.swift
//  Sweechat
//
//  Created by Hai Nguyen on 28/3/21.
//

import SwiftUI

struct HomeToolbarView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isShowingJoinView: Bool
    @Binding var isShowingAddView: Bool
    var body: some View {
        HStack {
            Button(action: {
                isShowingJoinView = true
                isShowingAddView = false
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .foregroundColor(ColorConstant.font1)
            }
            Button(action: {
                isShowingJoinView = false
                isShowingAddView = true
            }) {
                Image(systemName: "plus.app")
                    .foregroundColor(ColorConstant.font1)
            }

            NavigationLink(
                destination:
                    LazyNavView(
                        SettingsView(viewModel: viewModel.settingsViewModel))) {
                Image(systemName: "gear")
                    .foregroundColor(ColorConstant.font1)
            }

        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeToolbarView(
            viewModel: HomeViewModel(
                user: User(id: "8S781SDacTRSBYFQICIHxOS4sin1")
            ),
            isShowingJoinView: .constant(false),
            isShowingAddView: .constant(false))
    }
}
