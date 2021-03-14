import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        switch appViewModel.state {
        case .chatRoom:
            ChatRoomView(viewModel: appViewModel.chatRoomViewModel,
                         id: "1")
        case .entry:
            EntryView(viewModel: appViewModel.entryViewModel)
        case .onboarding:
            OnboardingView(viewModel: appViewModel.onboardingViewModel)
        case .login:
            LoginView(viewModel: appViewModel.loginViewModel)
        case .registration:
            RegistrationView(viewModel: appViewModel.registrationViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
