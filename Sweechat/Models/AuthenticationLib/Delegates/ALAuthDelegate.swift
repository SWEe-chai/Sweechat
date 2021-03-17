protocol ALAuthDelegate: AnyObject {
    func signIn(uid: String, name: String)
    func signOut()
}
