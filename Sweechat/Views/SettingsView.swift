import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapLogoutButton) {
                Text("Logout")
            }
            .foregroundColor(.red)
        }
    }
}
