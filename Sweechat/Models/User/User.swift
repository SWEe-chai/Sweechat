//
//  User.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

open class User: NSObject {

    var uid: UUID
    var username: String?
    var email: String
    var firstName: String?
    var lastName: String?
    var profilePictureURL: String?

    public init(uid: UUID, firstName: String, lastName: String, avatarURL: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
        self.email = email
        self.profilePictureURL = avatarURL
    }
}
