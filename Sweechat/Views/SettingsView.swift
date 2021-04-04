import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            Spacer()
            Button(action: viewModel.didTapLogoutButton) {
                HStack {
                    Spacer()
                    Text("Logout")
                        .font(FontConstant.Heading4)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(ColorConstant.medium)
                .cornerRadius(10)
            }
            Spacer()
        }.padding()
        .background(ColorConstant.base)
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
