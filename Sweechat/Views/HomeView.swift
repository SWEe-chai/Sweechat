import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            ForEach(viewModel.moduleViewModels) { moduleViewModel in
                NavigationLink(
                    destination: LazyNavView(viewModel.getModuleView(moduleViewModel))) {
                    Text(moduleViewModel.text)
                }
            }

            NavigationLink(
                destination: LazyNavView(viewModel.getSettingsView())) {
                Text("Settings")
            }
        }
        .navigationTitle(Text(viewModel.text))
        .navigationBarBackButtonHidden(true)
    }
}
