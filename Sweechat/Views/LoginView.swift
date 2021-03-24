import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            ForEach(viewModel.loginButtonViewModels, id: \.self) { loginButtonVM in
                LoginButtonView(viewModel: loginButtonVM)
            }
            NavigationLink(
                "",
                destination: LazyNavView(viewModel.getLoggedInView()),
                isActive: $viewModel.isLoggedIn)
                .hidden()
            .foregroundColor(.red)
        }
        .navigationBarBackButtonHidden(true)
    }
}
