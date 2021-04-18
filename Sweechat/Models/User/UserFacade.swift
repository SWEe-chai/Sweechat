import FirebaseFirestore

/**
 An interface through which the `User` model comunicates with the server.
 */
protocol UserFacade {
    /// An abstraction through which the server communicates with the calling object instance.
    var delegate: UserFacadeDelegate? { get set }

    /// Logs into the server and listens to changes to the specified `User`.
    /// - Parameters:
    ///   - user: The specified `User`.
    func loginAndListenToUser(_ user: User)
}
