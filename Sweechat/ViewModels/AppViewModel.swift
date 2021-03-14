import Foundation

class AppViewModel: ObservableObject {
    @Published var state: AppState

    init() {
        //state = AppState.onboarding
        state = AppState.chatRoom
    }

    var onboardingViewModel: OnboardingViewModel {
        let viewModel = OnboardingViewModel()
        viewModel.delegate = self
        return viewModel
    }

    var entryViewModel: EntryViewModel {
        let viewModel = EntryViewModel()
        viewModel.delegate = self
        return viewModel
    }

    var loginViewModel: LoginViewModel {
        LoginViewModel()
    }

    var registrationViewModel: RegistrationViewModel {
        RegistrationViewModel()
    }

    var chatRoomViewModel: ChatRoomViewModel {
        ChatRoomViewModel(id: "1")
}

    private func change(state: AppState) {
        self.state = state
    }
}

// MARK: OnboardingDelegate
extension AppViewModel: OnboardingDelegate {
    func navigateToEntry() {
        change(state: AppState.entry)
    }
}

// MARK: EntryDelegate
extension AppViewModel: EntryDelegate {
    func navigateToLogin() {
        change(state: AppState.login)
    }

    func navigateToRegistration() {
        change(state: AppState.registration)
    }
}
