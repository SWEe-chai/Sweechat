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

    init(viewModel: HomeViewModel, isShowingJoinView: Binding<Bool>) {
        self.viewModel = viewModel
        self._isShowingJoinView = isShowingJoinView
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        HStack {

            Toggle(isOn: $isShowingJoinView, label: {})
                .toggleStyle(ModuleOperationToggleStyle())

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
            isShowingJoinView: .constant(false))
    }
 }
