import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            ForEach(viewModel.loginButtonViewModels, id: \.self) { loginButtonVM in
                LoginButtonView(viewModel: loginButtonVM)
            }
            Button(action: viewModel.didTapBackButton) {
                Text("Back")
            }
            .foregroundColor(.red)
        }
    }
}
