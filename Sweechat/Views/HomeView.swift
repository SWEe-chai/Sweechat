import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapModuleButton) {
                Text("Module")
            }
            Button(action: viewModel.didTapSettingsButton) {
                Text("Settings")
            }
        }
    }
}
