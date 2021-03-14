import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel

    var body: some View {
        Text(viewModel.text)
    }
}
