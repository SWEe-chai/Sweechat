import Combine
import Foundation

class HomeViewModel: ObservableObject {
    weak var delegate: HomeViewModelDelegate?

    let user: User
    let settingsViewModel: SettingsViewModel
    let moduleList: ModuleList
    let notificationMetadata: NotificationMetadata
    var directModuleViewModel: ModuleViewModel

    @Published var isDirectModuleLoaded: Bool = false
    @Published var text: String = ""
    @Published var moduleViewModels: [ModuleViewModel] = []

    private var subscribers: [AnyCancellable] = []

    init(user: User, notificationMetadata: NotificationMetadata) {
        self.user = user
        self.text = "Welcome, \(user.name)!"
        self.moduleList = ModuleList.of(user)
        self.settingsViewModel = SettingsViewModel()
        self.directModuleViewModel = ModuleViewModel.createUnavailableInstance()
        self.notificationMetadata = notificationMetadata
        settingsViewModel.delegate = self
        initialiseSubscribers()
        handleRedirectionToModule()
    }

    func handleRedirectionToModule() {
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

    func handleModulesChange(modules: [Module]) {
        // Remove deleted modules
        let allModuleIds: Set<Identifier<Module>> = Set(modules.map { $0.id })
        self.moduleViewModels = self.moduleViewModels.filter { allModuleIds.contains($0.module.id) }

        // Add new modules
        let oldModuleIds = Set(self.moduleViewModels.map { $0.module.id })
        let newModuleVMs = modules
            .filter { !oldModuleIds.contains($0.id) }
            .map { ModuleViewModel(module: $0, user: user) }
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

    // MARK: Subscriptions
    private func initialiseSubscribers() {
        if !subscribers.isEmpty {
            return
        }
        initialiseNameSubscriber()
        initialiseModuleListSubscriber()
        initialiseNotificationMetadataSubscriber()
    }

    private func initialiseNameSubscriber() {
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome, \(newName)!"
        }

        subscribers.append(nameSubscriber)
    }

    private func initialiseModuleListSubscriber() {
        let moduleListSubscriber = moduleList.subscribeToModules { modules in
            self.handleModulesChange(modules: modules)
        }

        subscribers.append(moduleListSubscriber)
    }

    private func initialiseNotificationMetadataSubscriber() {
        let notificationMetadataSubscriber = self.notificationMetadata.subscribeToIsFromNotif { isFromNotif in
            if isFromNotif {
                self.handleRedirectionToModule()
            }
        }

        subscribers.append(notificationMetadataSubscriber)
    }
}

// MARK: SettingsViewModelDelegate
extension HomeViewModel: SettingsViewModelDelegate {
    func signOut() {
        delegate?.signOut()
    }
}
