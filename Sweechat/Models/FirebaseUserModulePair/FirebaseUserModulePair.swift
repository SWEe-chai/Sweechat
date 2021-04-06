//
//  FirebaseUserModule.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

class FirebaseUserModulePair {
    let userId: String
    let moduleId: String
    let permissions: ModulePermissionBitmask

    init(userId: String, moduleId: String, permissions: ModulePermissionBitmask) {
        self.userId = userId
        self.moduleId = moduleId
        self.permissions = permissions
    }
}
