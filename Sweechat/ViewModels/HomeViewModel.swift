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
        self.text = "Welcome, \(user.name)!"
        self.moduleList = ModuleList.of(user)
        self.settingsViewModel = SettingsViewModel()
        settingsViewModel.delegate = self
        initialiseSubscribers()
    }

    func initialiseSubscribers() {
        if !subscribers.isEmpty {
            return
        }
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome, \(newName)!"
        }
        let moduleListSubscriber = moduleList.subscribeToModules { modules in
            self.handleModulesChange(modules: modules)
        }
        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
    }

    func handleModulesChange(modules: [Module]) {
        let allModuleIds = Set(modules.map { $0.id })
        let oldModuleIds = Set(moduleViewModels.map { $0.module.id })
        self.moduleViewModels = self.moduleViewModels.filter { allModuleIds.contains($0.module.id) }
        let newModules = modules.filter { !oldModuleIds.contains($0.id) }
        self.moduleViewModels.append(
            contentsOf: newModules.map { ModuleViewModel(module: $0, user: user) })
    }

    func handleCreateModule(name: String) {
        // TODO: Currently module with yourself only
        let user = User(id: self.user.id)
        let users = [user]
        // The module owner is the only one in the module
        let currentUserPermissionPair = UserModulePermissionPair(
            userId: user.id,
            permissions: ModulePermission.moduleOwner)
        let userModulePermissionPairs = [currentUserPermissionPair]
        let module = Module(
            name: name,
            users: users,
            currentUser: user,
            currentUserPermission: currentUserPermissionPair.permissions
        )
        self.moduleList.store(module: module, userModulePermissions: userModulePermissionPairs)
    }

    func handleJoinModule(secret: String) {
        let id = Identifier<Module>(val: secret)
        moduleList.joinModule(moduleId: id)
    }
}

// MARK: SettingsViewModelDelegate
extension HomeViewModel: SettingsViewModelDelegate {
    func signOut() {
        delegate?.signOut()
    }
}
