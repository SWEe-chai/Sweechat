import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.didTapGoogleLogin) {
                Text("Log in with Google")
            }
            Button(action: viewModel.didTapFacebookLogin) {
                Text("Log in with Facebook")
            }
//            Button(action: viewModel.didTapHomeButton) {
//                Text("Home")
//            }
        }
    }
}
