import Firebase
import FacebookLogin

/**
 A representation of Facebook's authentication service.
 */
class ALFacebookAuthHandler: ALAuthHandler {
    weak var delegate: ALAuthHandlerDelegate?
    var type: ALAuthHandlerType {
        .facebook
    }
    private var manager = LoginManager()

    /// Initiates Facebook sign in.
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
