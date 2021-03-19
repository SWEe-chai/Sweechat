import Combine

class AppViewModel: ObservableObject {
    @Published var state: AppState
    var user: User
    var authentication: ALAuth
    var subscribers: [AnyCancellable]?

    init() {
        state = AppState.onboarding
        user = User.createUser()
        authentication = ALAuth()
        authentication.delegate = user
        initialiseSubscribers()
        // state = AppState.chatRoom
    }

    func initialiseSubscribers() {
        subscribers = []
        let signedInSubscriber = user.subscribeToSignedIn { userIsSignedIn in
            if !userIsSignedIn {
                return
            }
            self.change(state: .home)
        }
        subscribers?.append(signedInSubscriber)
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
        let viewModel = LoginViewModel(auth: authentication)
        viewModel.delegate = self
        return viewModel
    }

    var registrationViewModel: RegistrationViewModel {
        let viewModel = RegistrationViewModel()
        viewModel.delegate = self
        return viewModel
    }

    var chatRoomViewModel: ChatRoomViewModel {
        ChatRoomViewModel(id: "1")
    }

    var moduleViewModel: ModuleViewModel {
        ModuleViewModel()
    }

    var homeViewModel: HomeViewModel {
        let viewModel = HomeViewModel(user: user)
        viewModel.delegate = self
        return viewModel
    }

    var settingsViewModel: SettingsViewModel {
        let viewModel = SettingsViewModel()
        viewModel.delegate = self
        return viewModel
    }

    private func change(state: AppState) {
        self.state = state
    }
}

// MARK: LoggedOutDelegate
extension AppViewModel: LoggedOutDelegate {
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

// MARK: LoggedInDelegate
extension AppViewModel: LoggedInDelegate {
    func navigateToHome() {
        change(state: AppState.home)
    }
}

// MARK: HomeDelegate
extension AppViewModel: HomeDelegate {
    func navigateToModule() {
        change(state: AppState.module)
    }

    func navigateToSettings() {
        change(state: AppState.settings)
    }
}
