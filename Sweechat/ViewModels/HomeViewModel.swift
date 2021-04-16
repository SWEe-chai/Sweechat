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
    var directModuleViewModel: ModuleViewModel
    var notificationMetadata: NotificationMetadata

    init(user: User, notificationMetadata: NotificationMetadata) {
        self.user = user
        self.text = "Welcome, \(user.name)!"
        self.moduleList = ModuleList.of(user)
        self.settingsViewModel = SettingsViewModel()
        self.directModuleViewModel = ModuleViewModel.createUnavailableInstance()
        self.notificationMetadata = notificationMetadata
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
            self.moduleViewModels = modules.map {
                let moduleViewModel = ModuleViewModel(
                    module: $0,
                    user: self.user,
                    notificationMetadata: self.notificationMetadata
                )
                moduleViewModel.delegate = self
                return moduleViewModel
            }
        }
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
                if isFromNotif {
                    AsyncHelper.checkAsync(interval: AsyncHelper.shortInterval) {
                        if self
                            .getModuleViewModel(
                                moduleId: self.notificationMetadata.directModuleId
                            ) != nil {
                            return false
                        }
                        return true
                    }
                }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
        subscribers.append(notificationMetadataSubscriber)
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
        if let unwrappedDirectModuleViewModel = self.moduleViewModels.first(where: { $0.id == moduleId }) {
            self.directModuleViewModel = unwrappedDirectModuleViewModel
            self.isDirectModuleLoaded = true
        }
        return self.directModuleViewModel
    }
}

// MARK: SettingsViewModelDelegate
extension HomeViewModel: SettingsViewModelDelegate {
    func signOut() {
        delegate?.signOut()
    }
}

extension HomeViewModel: ModuleViewModelDelegate {
    func terminateNotificationResponse() {
        self.isDirectModuleLoaded = false
        self.notificationMetadata.reset()
    }
}
