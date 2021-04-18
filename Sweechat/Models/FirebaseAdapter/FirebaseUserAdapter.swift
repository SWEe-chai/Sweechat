//
//  FirebaseUserAdapter.swift
//  Sweechat
//
//  Created by Christian James Welly on 16/4/21.
//

import FirebaseFirestore
import os

struct FirebaseUserAdapter {
    static func convert(document: DocumentSnapshot) -> User {
        if !document.exists {
            os_log("Error: Cannot convert user, user document does not exist")
            return User.createUnavailableInstance()
        }
        let data = document.data()
        guard let idStr = data?[DatabaseConstant.User.id] as? String,
              let name = data?[DatabaseConstant.User.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for User, data: %s", String(describing: data))
            return User.createUnavailableInstance()
        }

        let id = Identifier<User>(val: idStr)
        return User(
            id: id,
            name: name,
            profilePictureUrl: profilePictureUrl
        )
    }

    static func convert(user: User) -> [String: Any] {
        [
            DatabaseConstant.User.id: user.id.val,
            DatabaseConstant.User.name: user.name,
            DatabaseConstant.User.profilePictureUrl: user.profilePictureUrl ?? "",
            DatabaseConstant.User.token: FcmJsonStorageManager.load() ?? ""
        ]
    }

    static func convert(userId: Identifier<User>, publicKeyBundleData: Data) -> [String: Any] {
        [
            DatabaseConstant.PublicKeyBundle.userId: userId.val,
            DatabaseConstant.PublicKeyBundle.bundleData: publicKeyBundleData
        ]
    }
}
