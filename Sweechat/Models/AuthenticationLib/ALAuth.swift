import Firebase
import SwiftUI

class ALAuth {
    private var authHandlers: [ALAuthHandlerType: ALAuthHandler] = [:]
    weak var delegate: ALAuthDelegate?

    func setUpGoogleHandler() {
        let googleAuth = ALGoogleAuthHandler()
        googleAuth.delegate = self
        authHandlers[.google] = googleAuth
    }

    func setUpFacebookHandler() {
        let facebookAuth = ALFacebookAuthHandler()
        facebookAuth.delegate = self
        authHandlers[.facebook] = facebookAuth
    }

    func initiateSignIn(type: ALAuthHandlerType) {
        guard let handler = authHandlers[type] else {
            fatalError("Authentication error: type \(type) is unknown")
        }
        handler.initiateSignIn()
    }
}

// MARK: ALAuthHandlerDelegate
extension ALAuth: ALAuthHandlerDelegate {
    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = authResult?.user else {
                print("FIREBASE: Unable to authenticate user.")
                return
            }
            let id: String = user.uid
            let displayName: String = user.displayName ?? ""
            let profilePictureUrl: String = user.photoURL?.absoluteString ?? ""
            self.delegate?.signIn(
                withDetails: ALLoginDetails(
                    id: id,
                    name: displayName,
                    profilePictureUrl: profilePictureUrl))
        }
    }

    func signOut() {
        delegate?.signOut()
    }
}
