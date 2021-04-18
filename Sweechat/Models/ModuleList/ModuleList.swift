import Combine
import Foundation

/**
 Represents a list of modules in the application.
 */
class ModuleList: ObservableObject {
    @Published var modules: [Module]

    private var moduleListFacade: ModuleListFacade?

    /// Returns a `ModuleList` belonging to the specified `User`.
    /// - Parameters:
    ///   - user: The specified `User`.
    /// - Returns: A `ModuleList` belonging to the specified `User`.
    static func of(_ user: User) -> ModuleList {
        let moduleList = ModuleList()
        moduleList.moduleListFacade = FirebaseModuleListFacade(user: user)
        moduleList.moduleListFacade?.delegate = moduleList
        return moduleList
    }

    // MARK: Initialization

    private init() {
        self.modules = []
        self.moduleListFacade = nil
    }

    // MARK: Facade Connection

    /// Stores the specified `Module` and associated user permissions on the server.
    /// - Parameters:
    ///   - module: The specified `Module`.
    ///   - userModulePermissions: The specified user permissions.
    func store(module: Module, userModulePermissions: [UserModulePermissionPair]) {
        self.moduleListFacade?.save(module: module, userModulePermissions: userModulePermissions)
    }

    /// Joins the `Module` with the specified ID from the application.
    /// - Parameters:
    ///   - moduleId: The specified module ID.
    func joinModule(moduleId: Identifier<Module>) {
        self.moduleListFacade?.joinModule(moduleId: moduleId)
    }

    // MARK: Subscriptions

    /// Subscribes to the this `ModuleList`'s modules by executing the specified function on change to the modules.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the modules.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToModules(function: @escaping ([Module]) -> Void) -> AnyCancellable {
        $modules.sink(receiveValue: function)
    }
}

// MARK: ModuleListFacadeDelegate
extension ModuleList: ModuleListFacadeDelegate {
    /// Inserts the specified `Module` into this `ModuleList`.
    /// - Parameters:
    ///   - module: The specified `Module`.
    func insert(module: Module) {
        if !self.modules.contains(module) {
            module.setModuleConnection()
            self.modules.append(module)
        }
    }

    /// Inserts the specified `Module`s into this `ModuleList`.
    /// - Parameters:
    ///   - modules: The specified `Module`s.
    func insertAll(modules: [Module]) {
        let newModules = modules.filter({ !modules.contains($0) })
        newModules.forEach { $0.setModuleConnection() }
        self.modules.append(contentsOf: newModules)
    }

    /// Removes the specified `Module` into this `ModuleList`.
    /// - Parameters:
    ///   - module: The specified `Module`.
    func remove(module: Module) {
        if let index = modules.firstIndex(of: module) {
            self.modules.remove(at: index)
        }
    }
}
