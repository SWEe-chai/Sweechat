import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            Text("Registration has not been implemented")
        }
        .navigationTitle(viewModel.text)
    }
}
