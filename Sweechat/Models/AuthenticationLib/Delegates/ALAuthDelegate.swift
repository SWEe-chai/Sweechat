protocol ALAuthDelegate: AnyObject {
    func signIn(withDetails: ALLoginDetails)
    func signOut()
}
