//
//  ModuleListFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 26/3/21.
//

protocol ModuleListFacade {
    var delegate: ModuleListFacadeDelegate? { get set }
    func save(module: Module)
    func joinModule(moduleId: String)
}
