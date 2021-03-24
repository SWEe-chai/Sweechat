import SwiftUI

struct EntryView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            NavigationLink(
                destination: LazyNavView(
                    LoginView(viewModel: viewModel.loginViewModel))) {
                Text("Login")
            }
            NavigationLink(
                destination: LazyNavView(
                    RegistrationView(viewModel: viewModel.registrationViewModel))) {
                Text("Register")
            }
        }
        .navigationTitle(Text("Entry"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
