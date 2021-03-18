import Firebase
import FirebaseFirestore
import SwiftUI

class ALAuth {
    private var authHandlers: [ALAuthHandlerType: ALAuthHandler] = [:]
    private var db = Firestore.firestore()
    weak var delegate: ALAuthDelegate?
    var loginDetails: ALLoginDetails?

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

    func getHandlerUI(type: ALAuthHandlerType) -> ALAuthHandler {
        guard let handler = authHandlers[type] else {
            fatalError("Authentication error: type \(type) is unknown")
        }
        return handler
    }

    private func getExistingLoginDetailsAndLogin(details: ALLoginDetails) {
        let uid = details.uid
        db.collection("users").document(uid).getDocument { document, _ in
            guard let document = document,
                  document.exists,
                  let name = document.data()?["name"] as? String,
                  let photo = document.data()?["photo"] as? String else {
                self.addNewUser(withDetails: details)
                self.delegate?.signIn(withDetails: details)
                return
            }
            self.delegate?.signIn(withDetails: ALLoginDetails(uid: uid, name: name, photo: photo))
        }
    }

    private func addNewUser(withDetails details: ALLoginDetails) {
        db.collection("users").document(details.uid).setData([
            "userid": details.uid,
            "name": details.name,
            "photo": details.photo
        ])
    }
}

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
            let uid: String = user.uid
            let displayName: String = user.displayName ?? ""
            let photo: String = user.photoURL?.absoluteString ?? ""
            let loginDetails = ALLoginDetails(uid: uid, name: displayName, photo: photo)

            self.getExistingLoginDetailsAndLogin(details: loginDetails)
        }
    }

    func signOut() {
        delegate?.signOut()
    }
}
