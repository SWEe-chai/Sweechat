import FirebaseFirestore

class FirebaseUserFacade: UserFacade {
    weak var delegate: UserFacadeDelegate?
    private var userId: String!

    static var db = Firestore.firestore()
    static var reference: DocumentReference?
    private static var userListener: ListenerRegistration?

    func loginAsUser(withDetails details: UserDetails) {
        userId = details.id
        FirebaseUserFacade.db.collection(DatabaseConstant.Collection.users).document(userId).getDocument { document, _ in
            guard let document = document,
                  document.exists else {
                // In this case user is a new user
                self.addUser(withDetails: details)
                return
            }
            self.setUpConnectionAsUser()
        }
    }

    private func addUser(withDetails details: UserDetails) {
        FirebaseUserFacade.db.collection(DatabaseConstant.Collection.users).document(details.id).setData([
                    DatabaseConstant.User.id: details.id,
                    DatabaseConstant.User.name: details.name,
                    DatabaseConstant.User.profilePictureUrl: details.profilePictureUrl
        ], completion: { _ in
            self.setUpConnectionAsUser()
        })
    }

    private func setUpConnectionAsUser() {
        if let userDetails = FirebaseUserFacade.getUserDetails(userId: userId) {
            self.delegate?.updateUserData(withDetails: userDetails)
        }
    }
    
    static func getUserDetails(userId: String) -> UserDetails? {
        reference = db.collection(DatabaseConstant.Collection.users).document(userId)
        var details: UserDetails? = nil
        userListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  let data = snapshot.data() else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            guard let id = data[DatabaseConstant.User.id] as? String,
                  let name = data[DatabaseConstant.User.name] as? String,
                  let profilePictureUrl = data[DatabaseConstant.User.profilePictureUrl] as? String else {
                print("Error reading data update for user")
                return
            }
            details = UserDetails(id: id,
                                      name: name,
                                      profilePictureUrl: profilePictureUrl,
                                      isLoggedIn: true)
        }
        return details
    }
}
