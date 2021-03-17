//
//  AuthHandlerDelegate.swift
//  SlackersTest
//
//  Created by Hai Nguyen on 12/3/21.
//

import Foundation
import Firebase

protocol ALAuthHandlerDelegate: AnyObject {
    func signIn(credential: AuthCredential)
    func signOut()
}
