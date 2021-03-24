import Combine

class HomeViewModel: ObservableObject {
    weak var delegate: HomeDelegate?
    var user: User
    var moduleViewModels: [ModuleViewModel]
    private var subscribers: [AnyCancellable] = []
    @Published var text: String = ""

    init(user: User) {
        self.user = user
        self.text = "Welcome home \(user.name)"
        // TODO: Load modules from facade instead
        moduleViewModels = [
            ModuleViewModel(user: user)
        ]
        initiateSubscribers()
    }

    private func initiateSubscribers() {
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome home \(newName)"
        }
        subscribers.append(nameSubscriber)
    }

    func getModuleView(_ moduleViewModel: ModuleViewModel) -> ModuleView {
        ModuleView(viewModel: moduleViewModel)
    }

    func getSettingsView() -> SettingsView {
        // TODO: Connect this Settings View Model if we want to
        // implement logout
        SettingsView(viewModel: SettingsViewModel())
    }
}
