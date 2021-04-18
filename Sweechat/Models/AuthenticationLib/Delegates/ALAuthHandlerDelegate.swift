import Firebase

/**
 An interface for signing in with third party authenticaion providers.
 */
protocol ALAuthHandlerDelegate: AnyObject {
    func signIn(credential: AuthCredential)
}
