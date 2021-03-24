import Firebase
import SwiftUI

class ALAuth {
    var authHandlers: [ALAuthHandler] = [
        ALGoogleAuthHandler(),
        ALFacebookAuthHandler()
    ]
    weak var delegate: ALAuthDelegate?

    // Initiate all auth handlers on init
    init() {
        for authHandler in authHandlers {
            authHandler.delegate = self
        }
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
