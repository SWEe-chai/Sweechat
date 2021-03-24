import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            ForEach(viewModel.loginButtonViewModels, id: \.self) { loginButtonVM in
                LoginButtonView(viewModel: loginButtonVM)
            }
            NavigationLink(
                "",
                destination: LazyNavView(
                    HomeView(viewModel: viewModel.homeViewModel)),
                isActive: $viewModel.isLoggedIn
            )
            .hidden()
        }
        .navigationTitle(Text(viewModel.text))
    }
}
