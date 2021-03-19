import FirebaseFirestore

protocol UserFacade {
    var db: Firestore { get }
    var reference: DocumentReference? { get }

    var delegate: UserFacadeDelegate? { get set }
    /// Registers the user if the user is not registered
    func loginAsUser(withDetails details: UserRepresentation)
    func getLoggedInUserDetails() -> UserRepresentation?
}
