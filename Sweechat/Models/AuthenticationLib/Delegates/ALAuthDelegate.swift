//
//  AuthDelegate.swift
//  SlackersTest
//
//  Created by Hai Nguyen on 12/3/21.
//

import Foundation

protocol ALAuthDelegate: AnyObject {
    func signIn(uid: String, name: String)
    func signOut()
}
