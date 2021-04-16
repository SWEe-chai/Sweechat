//
//  ModuleList.swift
//  Sweechat
//
//  Created by Agnes Natasya on 26/3/21.
//

import Combine
import Foundation

class ModuleList: ObservableObject {
    @Published var modules: [Module]

    private var moduleListFacade: ModuleListFacade?

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

    func store(module: Module, userModulePermissions: [UserModulePermissionPair]) {
        self.moduleListFacade?.save(module: module, userModulePermissions: userModulePermissions)
    }

    func joinModule(moduleId: Identifier<Module>) {
        self.moduleListFacade?.joinModule(moduleId: moduleId)
    }

    // MARK: Subscriptions

    func subscribeToModules(function: @escaping ([Module]) -> Void) -> AnyCancellable {
        $modules.sink(receiveValue: function)
    }
}

// MARK: ModuleListFacadeDelegate
extension ModuleList: ModuleListFacadeDelegate {
    func insert(module: Module) {
        if !self.modules.contains(module) {
            module.setModuleConnection()
            self.modules.append(module)
        }
    }

    func insertAll(modules: [Module]) {
        let newModules = modules.filter({ !modules.contains($0) })
        newModules.forEach { $0.setModuleConnection() }
        self.modules.append(contentsOf: newModules)
    }

    func remove(module: Module) {
        if let index = modules.firstIndex(of: module) {
            self.modules.remove(at: index)
        }
    }
}
