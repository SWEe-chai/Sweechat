//
//  FirebaseUserModule.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserModulePair {
    let userId: String
    let moduleId: Identifier<Module>
    let permissions: ModulePermissionBitmask

    init(userId: String, moduleId: Identifier<Module>, permissions: ModulePermissionBitmask) {
        self.userId = userId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
