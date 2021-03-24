import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
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
        .navigationTitle(Text(viewModel.text))
        .navigationBarBackButtonHidden(true)
    }
}
