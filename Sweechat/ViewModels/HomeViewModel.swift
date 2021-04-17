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
            self.handleModulesChange(modules: modules)
        }
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
            if isFromNotif {
                self.directModuleViewModel.getOut()
                self.isDirectModuleLoaded = false
                DispatchQueue.main.asyncAfter(deadline: .now() + AsyncHelper.longInterval) {
                    AsyncHelper.checkAsync(interval: AsyncHelper.shortInterval) {
                        if self.getModuleViewModel(moduleId: self.notificationMetadata.directModuleId) != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + AsyncHelper.longInterval) {
                            self.directModuleViewModel
                                .loadThisChatRoom(
                                    chatRoomId: self.notificationMetadata.directChatRoomId)
                            }
                            return false
                        }
                        return true
                    }
                }
            }
        }
        subscribers.append(nameSubscriber)
        subscribers.append(moduleListSubscriber)
        subscribers.append(notificationMetadataSubscriber)
    }

    func handleModulesChange(modules: [Module]) {
        // Remove deleted modules
        let allModuleIds: Set<Identifier<Module>> = Set(modules.map { $0.id })
        self.moduleViewModels = self.moduleViewModels.filter { allModuleIds.contains($0.module.id) }

        // Add new modules
        let oldModuleIds = Set(self.moduleViewModels.map { $0.module.id })
        let newModuleVMs = modules
            .filter { !oldModuleIds.contains($0.id) }
            .map { ModuleViewModel(module: $0, user: user, notificationMetadata: notificationMetadata) }
        self.moduleViewModels.append(contentsOf: newModuleVMs)
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
