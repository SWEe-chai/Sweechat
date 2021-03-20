import FirebaseFirestore
import os

class FirebaseUserFacade: UserFacade {
    weak var delegate: UserFacadeDelegate?
    private var userId: String!

    var db = Firestore.firestore()
    var reference: DocumentReference?
    private var userListener: ListenerRegistration?

    init(userId: String) {
        self.userId = userId
    }

    func loginAndListenToUser(withDetails details: UserRepresentation) {
        userId = details.id
        self.db.collection(DatabaseConstant.Collection.users).document(userId).getDocument { document, _ in
            guard let document = document,
                  document.exists else {
                // In this case user is a new user
                self.addUser(withDetails: details)
                return
            }
            self.setUpConnectionAsUser()
        }
    }

    private func addUser(withDetails details: UserRepresentation) {
        self.db
            .collection(DatabaseConstant.Collection.users)
            .document(details.id)
            .setData(
                FirebaseUserFacade
                    .convert(userDetails: details), completion: { _ in
            self.setUpConnectionAsUser()
                    }
            )
    }

    private func setUpConnectionAsUser() {
        if userId.isEmpty {
            os_log("User id is empty when attempting set up connection to user")
            return
        }
        reference = db.collection(DatabaseConstant.Collection.users).document(userId)
        userListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            if let details = FirebaseUserFacade.convert(document: snapshot) {
                self.delegate?.updateUserData(withDetails: details)
            }
        }
    }

    static func convert(document: DocumentSnapshot) -> UserRepresentation? {
        if !document.exists {
            os_log("Error: Cannot convert user, user document does not exist")
            return nil
        }
        let data = document.data()
        var details: UserRepresentation?
        guard let id = data?[DatabaseConstant.User.id] as? String,
              let name = data?[DatabaseConstant.User.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for user")
            return nil
        }
        details = UserRepresentation(
            id: id,
            name: name,
            profilePictureUrl: profilePictureUrl,
            isLoggedIn: true
        )

        return details
    }

    static func convert(userDetails: UserRepresentation) -> [String: Any] {
        [
            DatabaseConstant.User.id: userDetails.id,
            DatabaseConstant.User.name: userDetails.name,
            DatabaseConstant.User.profilePictureUrl: userDetails.profilePictureUrl ?? ""
        ]

    }
}
