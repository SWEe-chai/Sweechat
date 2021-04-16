//
//  FirebaseModuleAdapter.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/4/21.
//

import FirebaseFirestore
import os

struct FirebaseModuleAdapter {
    // Since modules need to have a user, to convert, we need to have the user
    static func convert(document: DocumentSnapshot,
                        user: User,
                        withPermissions permissions: ModulePermissionBitmask) -> Module? {
        if !document.exists {
            os_log("Error: Cannot convert module, module document does not exist")
            return nil
        }
        let data = document.data()
        guard let idStr = data?[DatabaseConstant.Module.id] as? String,
              let name = data?[DatabaseConstant.Module.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for Module, data: %s", String(describing: data))
            return nil
        }

        let id = Identifier<Module>(val: idStr)
        return Module(
            id: id,
            name: name,
            currentUser: user,
            currentUserPermission: permissions,
            profilePictureUrl: profilePictureUrl
        )
    }

    static func convert(module: Module) -> [String: Any] {
        [
            DatabaseConstant.Module.id: module.id.val,
            DatabaseConstant.Module.name: module.name,
            DatabaseConstant.Module.profilePictureUrl: module.profilePictureUrl ?? ""
        ]
    }
}
