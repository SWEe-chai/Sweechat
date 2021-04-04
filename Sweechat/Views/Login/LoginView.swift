import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to SweeChat!")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding()
            Divider().padding()
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
            Spacer()
        }
        .background(ColorConstant.base)
        .navigationBarTitleDisplayMode(.inline)
    }
}
