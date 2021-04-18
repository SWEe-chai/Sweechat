import FirebaseFirestore

protocol UserFacade {
    /// An abstraction through which the server communicates with the calling object instance.
    var delegate: UserFacadeDelegate? { get set }

    /// Logs into the server and listens to changes to the specified `User`.
    func loginAndListenToUser(_ user: User)
}
