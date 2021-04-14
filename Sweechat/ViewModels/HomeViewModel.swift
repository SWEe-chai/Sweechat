import Combine
import Foundation

class HomeViewModel: ObservableObject {
    var user: User
    weak var delegate: HomeViewModelDelegate?
    var settingsViewModel: SettingsViewModel
    var moduleList: ModuleList
    @Published var isDirectModuleLoaded: Bool = false
    @Published var text: String = ""
    @Published var moduleViewModels: [ModuleViewModel] = []
    private var subscribers: [AnyCancellable] = []

    init(user: User, notificationMetadata: NotificationMetadata) {
        self.user = user
        self.text = "Welcome, \(user.name)!"
        self.moduleList = ModuleList.of(user)
        self.settingsViewModel = SettingsViewModel()
        settingsViewModel.delegate = self
        initialiseSubscribers()
        if notificationMetadata.isFromNotif {
            checkAsync(interval: 0.1) {
                if self
                    .getModuleViewModel(
                        moduleId: notificationMetadata.directModuleId
                    ) != nil {
                    return false
                }
                return true
            }
        }
    }

    func initialiseSubscribers() {
        if !subscribers.isEmpty {
            return
        }
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome, \(newName)!"
        }
        let moduleListSubscriber = moduleList.subscribeToModules { modules in
            self.moduleViewModels = modules.map { ModuleViewModel(module: $0, user: self.user) }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
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

    func getModuleViewModel(moduleId: String) -> ModuleViewModel? {
        var directModuleViewModel = self.moduleViewModels.filter { $0.id == moduleId }.first
        return directModuleViewModel
    }
    
    func checkAsync(interval: Double, repeatableFunction: @escaping () -> Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if repeatableFunction() {
                self.checkAsync(interval: interval, repeatableFunction: repeatableFunction)
            }
        }
    }
}

// MARK: SettingsViewModelDelegate
extension HomeViewModel: SettingsViewModelDelegate {
    func signOut() {
        delegate?.signOut()
    }
}
