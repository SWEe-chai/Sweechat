import Firebase
import SwiftUI
import os

/**
 A library for connecting to third-party authentication providers.
 */
class ALAuth {
    var authHandlers: [ALAuthHandler] = [
        ALGoogleAuthHandler(),
        ALFacebookAuthHandler()
    ]
    weak var delegate: ALAuthDelegate?

    /// Constructs an `ALAuth` instance with all of the chosen third-party authentication providers.
    init() {
        for authHandler in authHandlers {
            authHandler.delegate = self
        }
    }

    /// Signs in with information from the previous session.
    func signInWithPreviousSession() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        signInAs(user: user)
    }

    private func signInAs(user: Firebase.User) {
        let id: String = user.uid
        let displayName: String = user.displayName ?? ""
        let profilePictureUrl: String = user.photoURL?.absoluteString ?? ""
        self.delegate?.signIn(
            withDetails: ALLoginDetails(
                id: id,
                name: displayName,
                profilePictureUrl: profilePictureUrl))
    }

    /// Signs out of the current authentication provider.
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            os_log("ALAuth: Signout error: \(error.localizedDescription)")
        }
    }
}

// MARK: ALAuthHandlerDelegate
extension ALAuth: ALAuthHandlerDelegate {
    /// Signs in with the specified `AuthCredential`.
    /// - Parameters:
    ///   - credential: The specified `AuthCredential`.
    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                os_log("ALAuth: Error when signing in \(error.localizedDescription)")
                return
            }
            guard let user: Firebase.User = authResult?.user else {
                os_log("FIREBASE: Unable to authenticate user.")
                return
            }
            self.signInAs(user: user)
        }
    }
}
