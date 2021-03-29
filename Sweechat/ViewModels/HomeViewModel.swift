import Combine
import Foundation
class HomeViewModel: ObservableObject {
    var user: User
    weak var delegate: HomeViewModelDelegate?
    var settingsViewModel: SettingsViewModel
    var moduleList: ModuleList
    @Published var text: String = ""
    @Published var moduleViewModels: [ModuleViewModel] = []
    private var subscribers: [AnyCancellable] = []

    init(user: User) {
        self.user = user
        self.text = "Welcome home \(user.name)"
        self.moduleList = ModuleList.of(user.id)
        self.settingsViewModel = SettingsViewModel()
        settingsViewModel.delegate = self
        initialiseSubscribers()
    }

    func initialiseSubscribers() {
        if !subscribers.isEmpty {
            return
        }
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome home \(newName)"
        }
        let moduleListSubscriber = moduleList.subscribeToModules { modules in
            self.moduleViewModels = modules.map { ModuleViewModel(module: $0, user: self.user) }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
    }

    func handleCreateModule(name: String) {
        // TODO: Currently module with yourself only
        let users = [
            User(id: user.id)
        ]
        let module = Module(
            name: name,
            users: users
        )
        self.moduleList.store(module: module)
    }

    func handleJoinModule(secret: String) {
        let id = secret
        moduleList.joinModule(moduleId: id)
    }
}

// MARK: SettingsViewModelDelegate
extension HomeViewModel: SettingsViewModelDelegate {
    func signOut() {
        delegate?.signOut()
    }
}
