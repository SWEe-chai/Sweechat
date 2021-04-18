/**
 An interface through which the third party authentication provider communicates with the calling client application.
 */
protocol ALAuthDelegate: AnyObject {
    func signIn(withDetails: ALLoginDetails)
    func signOut()
}
