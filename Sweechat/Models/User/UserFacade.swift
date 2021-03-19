import FirebaseFirestore

protocol UserFacade {
    static var db: Firestore { get }
    static var reference: DocumentReference? { get }

    var delegate: UserFacadeDelegate? { get set }
    /// Registers the user if the user is not registered
    func loginAsUser(withDetails details: UserDetails)
    static func getUserDetails(userId: String) -> UserDetails?
}
