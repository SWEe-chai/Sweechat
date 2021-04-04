//
//  HomeToolbarView.swift
//  Sweechat
//
//  Created by Hai Nguyen on 28/3/21.
//

import SwiftUI

struct HomeToolbarView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isShowingCreateView: Bool

    init(viewModel: HomeViewModel, isShowingCreateView: Binding<Bool>) {
        self.viewModel = viewModel
        self._isShowingCreateView = isShowingCreateView
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        HStack {

            Toggle(isOn: $isShowingCreateView, label: {})
                .toggleStyle(ModuleOperationToggleStyle())

            NavigationLink(
                destination:
                    LazyNavView(
                        SettingsView(viewModel: viewModel.settingsViewModel))) {
                Image(systemName: "gear")
                    .foregroundColor(ColorConstant.dark)
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
            isShowingCreateView: .constant(false))
    }
 }
