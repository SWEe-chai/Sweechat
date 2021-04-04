import SwiftUI

struct LoginButtonView: View {
    var viewModel: LoginButtonViewModel

    var body: some View {
        Button(action: viewModel.tapped) {
            HStack {
                Spacer()
                Image(viewModel.text)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text("Login with \(viewModel.text)")
                    .font(FontConstant.Heading4)
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(viewModel.backgroundColor)
            .cornerRadius(10)
        }
    }
}
