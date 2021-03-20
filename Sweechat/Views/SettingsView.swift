import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: {}) {
                Text("Logout (not implemented)")
            }
            Button(action: viewModel.didTapBackButton) {
                Text("Back")
            }
            .foregroundColor(.red)
        }
    }
}
