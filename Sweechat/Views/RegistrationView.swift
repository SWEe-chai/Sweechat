import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Text("Registration has not been implemented")
            Button(action: viewModel.didTapBackButton) {
                Text("Back")
            }
            .foregroundColor(.red)
        }
    }
}
