import Firebase
import GoogleSignIn
import UserNotifications

/**
 A representation of Google's authentication service.
 */
class ALGoogleAuthHandler: NSObject, GIDSignInDelegate, ALAuthHandler {
    weak var delegate: ALAuthHandlerDelegate?
    var type: ALAuthHandlerType {
        .google
    }

    /// Constructs an instance of `ALGoogleAuthHandler`.
    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    /// Initiates Google sign in.
    func initiateSignIn() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }

    /// A helper method for Google API sign in.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: nil)
            return
        }

        guard let authentication = user.authentication else {
            return
        }

        let credential = GoogleAuthProvider
            .credential(withIDToken: authentication.idToken,
                        accessToken: authentication.accessToken)

        delegate?.signIn(credential: credential)
    }

    /// A helper method for Google API sign in.
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
    }
}
