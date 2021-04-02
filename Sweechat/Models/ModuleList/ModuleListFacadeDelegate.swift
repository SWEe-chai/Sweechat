//
//  ModuleListFacadeDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 26/3/21.
//

protocol ModuleListFacadeDelegate: AnyObject {
    func insert(module: Module)
    func insertAll(modules: [Module])
    func remove(module: Module)
}
