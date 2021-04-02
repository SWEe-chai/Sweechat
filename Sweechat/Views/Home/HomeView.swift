import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingJoinView: Bool = false
    @State var isShowingAddView: Bool = false

    var body: some View {
        ZStack {
            VStack {
                ForEach(viewModel.moduleViewModels) { moduleViewModel in
                    ModuleItemView(viewModel: moduleViewModel)
                }

                NavigationLink(
                    destination:
                        LazyNavView(
                            SettingsView(viewModel: viewModel.settingsViewModel))) {
                    Text("Settings")
                }
            }
            if isShowingAddView {
                AddModuleView(
                    isShowing: $isShowingAddView,
                    viewModel: viewModel
                )
            }
            if isShowingJoinView {
                JoinModuleView(
                    isShowing: $isShowingJoinView,
                    viewModel: viewModel
                )
            }
        }
        .toolbar {
            HomeToolbarView(
                isShowingJoinView: $isShowingJoinView,
                isShowingAddView: $isShowingAddView)
        }
        .navigationTitle(Text(viewModel.text))
        .navigationBarBackButtonHidden(true)
    }
}

// This is added so that the list item updates when the module updates
struct ModuleItemView: View {
    @ObservedObject var viewModel: ModuleViewModel
    var body: some View {
        NavigationLink(
            destination:
                LazyNavView(ModuleView(viewModel: viewModel))) {
            Text(viewModel.text)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: HomeViewModel(
                user: User(id: "8S781SDacTRSBYFQICIHxOS4sin1")
            )
        )
    }
}
