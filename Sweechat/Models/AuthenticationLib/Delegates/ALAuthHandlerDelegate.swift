import Firebase

protocol ALAuthHandlerDelegate: AnyObject {
    func signIn(credential: AuthCredential)
}
