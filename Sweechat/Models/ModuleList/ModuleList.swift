//
//  ModuleList.swift
//  Sweechat
//
//  Created by Agnes Natasya on 26/3/21.
//

import Foundation
import Combine

class ModuleList {
    @Published var modules: [Module] {
        willSet {
            objectWillChange.send()
        }
    }
    private var moduleListFacade: ModuleListFacade?
    
    static func of(_ userId: String) -> ModuleList {
        let moduleList = ModuleList()
        moduleList.moduleListFacade = FirebaseModuleListFacade(userId: userId)
        moduleList.moduleListFacade?.delegate = moduleList
        return moduleList
    }

    private init() {
        self.modules = []
        self.moduleListFacade = nil
    }
}

// MARK: ModuleListFacadeDelegate
extension ModuleList: ModuleListFacadeDelegate {
    func insert(module: Module) {
        guard !self.modules.contains(module) else {
            return
        }
        self.modules.append(module)
    }

    func insertAll(modules: [Module]) {
        self.modules = modules
    }

    func remove(module: Module) {
        if let index = modules.firstIndex(of: module) {
            self.modules.remove(at: index)
        }
    }
    
    func update(module: Module) {
        if let index = modules.firstIndex(of: module) {
            self.modules[index] = module
        }
    }

}

