import SwiftUI

struct LoginButtonView: View {
    var viewModel: LoginButtonViewModel

    var body: some View {
        Button(viewModel.text, action: viewModel.tapped)
    }
}
