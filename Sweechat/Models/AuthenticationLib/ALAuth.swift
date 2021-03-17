//
//  File.swift
//  SlackersTest
//
//  Created by Hai Nguyen on 12/3/21.
//

import Firebase
import SwiftUI

class ALAuth {
    private var authHandlers: [ALAuthHandlerType: ALAuthHandler] = [:]
    var delegate: ALAuthDelegate?

    init() {
        setUpAuthHandlers();
    }

    func setUpAuthHandlers() {
        let googleAuth = ALGoogleAuthHandler()
        googleAuth.delegate = self
        authHandlers[.google] = googleAuth
        let facebookAuth = ALFacebookAuthHandler()
        facebookAuth.delegate = self
        authHandlers[.facebook] = facebookAuth
    }

    func getHandlerUI(type: ALAuthHandlerType) -> ALAuthHandler {
        guard let handler = authHandlers[type] else {
            fatalError("Authentication error: type \(type) is unknown")
        }
        return handler
    }
}

extension ALAuth: ALAuthHandlerDelegate {
    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = authResult?.user else {
                print("FIREBASE: Unable to authenticate user.")
                return
            }
            self.delegate?.signIn(uid: user.uid, name: user.displayName ?? "")
        }
    }

    func signOut() {
        delegate?.signOut()
    }
}
