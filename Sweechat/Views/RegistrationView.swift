import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapHomeButton) {
                Text("Home")
            }
        }
    }
}
