import SwiftUI

struct LoginButtonView: View {
    var viewModel: LoginButtonViewModel

    var body: some View {
        Button(action: viewModel.tapped) {
            HStack {
                Text("Login with \(viewModel.text)")
                    .font(FontConstant.Heading1)
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.backgroundColor)
                    .cornerRadius(10)
            }
        }
    }
}
