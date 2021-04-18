import FirebaseFirestore

protocol UserFacade {
    var delegate: UserFacadeDelegate? { get set }
    /// Registers the user if the user is not registered
    func loginAndlistenToUser(_ user: User)
}
