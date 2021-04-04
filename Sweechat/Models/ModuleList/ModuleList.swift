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

    private init() {
        self.modules = []
        self.moduleListFacade = nil
    }

    func store(module: Module) {
        self.moduleListFacade?.save(module: module)
    }

    func joinModule(moduleId: String) {
        self.moduleListFacade?.joinModule(moduleId: moduleId)
    }

    func subscribeToModules(function: @escaping ([Module]) -> Void) -> AnyCancellable {
        $modules.sink(receiveValue: function)
    }
}

// MARK: ModuleListFacadeDelegate
extension ModuleList: ModuleListFacadeDelegate {
    func insert(module: Module) {
        guard !self.modules.contains(module) else {
            return
        }
        module.setModuleConnection()
        self.modules.append(module)
    }

    func insertAll(modules: [Module]) {
        modules.forEach { $0.setModuleConnection() }
        self.modules = modules
    }

    func remove(module: Module) {
        if let index = modules.firstIndex(of: module) {
            self.modules.remove(at: index)
        }
    }
}
