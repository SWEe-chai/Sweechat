import SwiftUI

struct EntryView: View {
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapLoginButton) {
                Text("Login")
            }
            Button(action: viewModel.didTapRegistrationButton) {
                Text("Registration")
            }
        }
    }
}
