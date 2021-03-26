import Combine

class HomeViewModel: ObservableObject {
    var user: User
    var settingsViewModel: SettingsViewModel
    private var subscribers: [AnyCancellable] = []
    var moduleList: ModuleList
    @Published var text: String = ""
    var moduleViewModels: [ModuleViewModel] {
        moduleList.modules.map {
            ModuleViewModel(id: $0.id, name: $0.name, user: user)
        }
    }

    init(user: User) {
        self.user = user
        self.text = "Welcome home \(user.name)"
        self.moduleList = ModuleList.of(user.id)
        // TODO: Connect this Settings View Model if we want to
        // implement logout
        self.settingsViewModel = SettingsViewModel()
        initiateSubscribers()
    }

    private func initiateSubscribers() {
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome home \(newName)"
        }
        let moduleListSubscriber = moduleList.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }

        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
    }

    func handleCreateModule() {
        let users = [
            User(id: "39DI0eqPZabWv3nPLEvmHkeTxoo2"),
            User(id: "CWdDxGgOMLdrQd62b7CR6qBkQaG3")
        ]
        let module = Module(
            name: "Dummy Module by Agnes",
            users: users
        )
        self.moduleList.store(module: module)
    }

}
