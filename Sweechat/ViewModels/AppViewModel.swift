import Combine
import os

class AppViewModel: ObservableObject {
    @Published var state: AppState
    var user: User
    var authentication: ALAuth
    var subscribers: [AnyCancellable]?

    init() {
        state = AppState.entry
        user = User.createDummyUser()
        authentication = ALAuth()
        authentication.delegate = user
        initialiseSubscribers()

        // During development, this assertion below may be commented
        if !isValidState(state) {
            changeToDefaultState()
            return
        }
    }

    private func initialiseSubscribers() {
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
        let viewModel = ChatRoomViewModel(id: "3", user: user)
        viewModel.delegate = self
        return viewModel
    }

    var moduleViewModel: ModuleViewModel {
        let viewModel = ModuleViewModel()
        viewModel.delegate = self
        return viewModel
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

    private func change(state newState: AppState) {
        if !isValidState(newState) {
            changeToDefaultState()
            return
        }
        self.state = newState
    }

    private func isValidState(_ state: AppState) -> Bool {
        if user.isLoggedIn {
            return StateConstant.LoggedInAppStates.contains(state)
        } else {
            return StateConstant.LoggedOutAppStates.contains(state)
        }
    }

    private func changeToDefaultState() {
        if user.isLoggedIn {
            os_log(StateConstant.DefaultLoggedInAppStateMessage)
            self.state = StateConstant.DefaultLoggedInAppState
        } else {
            os_log(StateConstant.DefaultLoggedOutAppStateMessage)
            self.state = StateConstant.DefaultLoggedOutAppState
        }
    }
}

// MARK: LoggedOutDelegate
extension AppViewModel: LoggedOutDelegate {
    func navigateToEntryFromLoggedOut() {
        change(state: AppState.entry)
    }

    func navigateToHomeFromLoggedOut() {
        change(state: AppState.home)
    }
}

// MARK: EntryDelegate
extension AppViewModel: EntryDelegate {
    func navigateToLoginFromEntry() {
        change(state: AppState.login)
    }

    func navigateToRegistrationFromEntry() {
        change(state: AppState.registration)
    }
}

// MARK: ModuleDelegate
extension AppViewModel: ModuleDelegate {
    func navigateToChatRoomFromModule() {
        change(state: AppState.chatRoom)
    }

    func navigateToHomeFromModule() {
        change(state: AppState.home)
    }
}

// MARK: LoggedInDelegate
extension AppViewModel: LoggedInDelegate {
    func navigateToHomeFromLoggedIn() {
        change(state: AppState.home)
    }

    func navigateToEntryFromLoggedIn() {
        change(state: AppState.entry)
    }
}

// MARK: HomeDelegate
extension AppViewModel: HomeDelegate {
    func navigateToModuleFromHome() {
        change(state: AppState.module)
    }

    func navigateToSettingsFromHome() {
        change(state: AppState.settings)
    }
}

// MARK: ChatRoomDelegate
extension AppViewModel: ChatRoomDelegate {
    func navigateToModuleFromChatRoom() {
        change(state: AppState.module)
    }
}
