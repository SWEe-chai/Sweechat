import Combine

class HomeViewModel: ObservableObject {
    var user: User
    var moduleViewModels: [ModuleViewModel]
    var settingsViewModel: SettingsViewModel
    private var subscribers: [AnyCancellable] = []
    @Published var text: String = ""

    init(user: User) {
        self.user = user
        self.text = "Welcome home \(user.name)"
        // TODO: Load modules from facade instead
        moduleViewModels = [
            ModuleViewModel(user: user)
        ]
        // TODO: Connect this Settings View Model if we want to
        // implement logout
        self.settingsViewModel = SettingsViewModel()
        initiateSubscribers()
    }

    private func initiateSubscribers() {
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome home \(newName)"
        }
        subscribers.append(nameSubscriber)
    }
}
