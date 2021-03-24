protocol LoggedInDelegate: AnyObject {
    func navigateToEntryFromLoggedIn()
    func getLoggedInView() -> HomeView
}
