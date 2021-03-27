import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            Text("Create Module")
                .onTapGesture {
                    viewModel.handleCreateModule()
                }

            ForEach(viewModel.moduleViewModels) { moduleViewModel in
                NavigationLink(
                    destination:
                        LazyNavView(ModuleView(viewModel: moduleViewModel))) {
                    ModuleItemView(viewModel: moduleViewModel)
                }
            }

            NavigationLink(
                destination:
                    LazyNavView(
                        SettingsView(viewModel: viewModel.settingsViewModel))) {
                Text("Settings")
            }
        }
        .onAppear { viewModel.initialiseSubscribers() }
//        .onDisappear { viewModel.removeSubscribers() }
        .navigationTitle(Text(viewModel.text))
        .navigationBarBackButtonHidden(true)
    }
}

struct ModuleItemView: View {
    @ObservedObject var viewModel: ModuleViewModel
    var body: some View {
        Text(viewModel.text)
    }
}
