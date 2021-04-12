//
//  FirebaseUserModuleFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//
import FirebaseFirestore
import os

class FirebaseUserModulePairFacade {
    static func convert(document: DocumentSnapshot) -> FirebaseUserModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userId = data?[DatabaseConstant.UserModulePair.userId] as? String,
              let moduleIdStr = data?[DatabaseConstant.UserModulePair.moduleId] as? String,
              let permissions = data?[DatabaseConstant.UserModulePair.permissions] as? ModulePermissionBitmask else {
            os_log("Error converting data for UserModulePair, data: %s", String(describing: data))
            return nil
        }

        let moduleId = Identifier<Module>(val: moduleIdStr)
        return FirebaseUserModulePair(userId: userId, moduleId: moduleId, permissions: permissions)
    }

    static func convert(pair: FirebaseUserModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserModulePair.userId: pair.userId,
            DatabaseConstant.UserModulePair.moduleId: pair.moduleId.val,
            DatabaseConstant.UserModulePair.permissions: pair.permissions
        ]
    }
}
