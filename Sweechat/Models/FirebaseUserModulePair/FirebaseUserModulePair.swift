//
//  FirebaseUserModule.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserModulePair {
    let userId: Identifier<User>
    let moduleId: Identifier<Module>
    let permissions: ModulePermissionBitmask

    init(userId: Identifier<User>, moduleId: Identifier<Module>, permissions: ModulePermissionBitmask) {
        self.userId = userId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
