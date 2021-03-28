import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingJoinView: Bool = false
    @State var isShowingAddView: Bool = false

    var body: some View {
        ZStack {
            VStack {
                ForEach(viewModel.moduleViewModels) { moduleViewModel in
                    NavigationLink(
                        destination:
                            LazyNavView(ModuleView(viewModel: moduleViewModel))) {
                        Text(moduleViewModel.text)
                    }
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
        .toolbar(content: {
            HStack {
                Button(action: {
                    isShowingJoinView = true
                    isShowingAddView = false
                }) {
                    Image(systemName: "plus.magnifyingglass")
                }
                Button(action: {
                    isShowingJoinView = false
                    isShowingAddView = true
                }) {
                    Image(systemName: "plus.app")
                }
            }
        })
        .navigationTitle(Text(viewModel.text))
        .navigationBarBackButtonHidden(true)
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
