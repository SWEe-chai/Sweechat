//
//  FirebaseUserModuleFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 25/3/21.
//

import FirebaseFirestore
import os

class FirebaseUserModulePairFacade {
    private var db = Firestore.firestore()
    private var reference: DocumentReference?

    static func convert(document: DocumentSnapshot) -> FirebaseUserModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userId = data?[DatabaseConstant.UserModulePair.userId] as? String,
              let moduleId = data?[DatabaseConstant.UserModulePair.moduleId] as? String else {
            return nil
        }

        return FirebaseUserModulePair(userId: userId, moduleId: moduleId)
    }

    static func convert(pair: FirebaseUserModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserModulePair.userId: pair.userId,
            DatabaseConstant.UserModulePair.moduleId: pair.moduleId
        ]
    }
}
