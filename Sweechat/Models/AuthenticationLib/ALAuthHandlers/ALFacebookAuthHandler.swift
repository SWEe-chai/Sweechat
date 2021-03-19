import Firebase
import FacebookLogin

class ALFacebookAuthHandler: ALAuthHandler {
    weak var delegate: ALAuthHandlerDelegate?
    var manager = LoginManager()

    func initiateSignIn() {
        manager.logIn(
            permissions:
                [ALConstants.Facebook.publicProfile,
                 ALConstants.Facebook.email],
            from: nil) { _, err in
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
