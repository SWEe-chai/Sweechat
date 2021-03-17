//
//  FacebookAuthHandler.swift
//  SlackersTest
//
//  Created by Hai Nguyen on 17/3/21.
//

import Foundation
import Firebase
import FacebookLogin

class ALFacebookAuthHandler: ALAuthHandler {
    let publicProfile = "public_profile"
    let email = "email"
    weak var delegate: ALAuthHandlerDelegate?
    var manager = LoginManager()

    func initiateSignIn() {
        manager.logIn(permissions: [publicProfile, email], from: nil) { _, err in
            if let err = err {
                print("Login Error: Unable to login - \(err)")
                return
            }
            guard let token = AccessToken.current else {
                print("Login Error: Unable to obtain token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
            self.delegate?.signIn(credential: credential)
        }
    }

}
