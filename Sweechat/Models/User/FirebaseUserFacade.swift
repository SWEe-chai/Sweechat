import FirebaseFirestore
import os

class FirebaseUserFacade: UserFacade {
    weak var delegate: UserFacadeDelegate?
    private var userId: String

    var db = Firestore.firestore()
    var reference: DocumentReference?
    private var userListener: ListenerRegistration?

    init(userId: String) {
        self.userId = userId
    }

    func loginAndListenToUser(_ user: User) {
        userId = user.id
        self.db.collection(DatabaseConstant.Collection.users).document(userId).getDocument { document, _ in
            guard let document = document,
                  document.exists else {
                // In this case user is a new user
                self.addUser(user)
                return
            }
            self.setUpConnectionAsUser()
        }
    }

    private func addUser(_ user: User) {
        self.db
            .collection(DatabaseConstant.Collection.users)
            .document(user.id)
            .setData(
                FirebaseUserFacade
                    .convert(user: user), completion: { _ in
            self.setUpConnectionAsUser()
                    }
            )
    }

    private func setUpConnectionAsUser() {
        if userId.isEmpty {
            os_log("Error loading user: User id is empty")
            return
        }
        reference = db.collection(DatabaseConstant.Collection.users).document(userId)
        userListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            if let user = FirebaseUserFacade.convert(document: snapshot) {
                self.delegate?.updateUser(user: user)
            }
        }
    }

    static func convert(document: DocumentSnapshot) -> User? {
        if !document.exists {
            os_log("Error: Cannot convert user, user document does not exist")
            return nil
        }
        let data = document.data()
        guard let id = data?[DatabaseConstant.User.id] as? String,
              let name = data?[DatabaseConstant.User.name] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String else {
            os_log("Error converting data for user")
            return nil
        }
        return User(
            id: id,
            name: name,
            profilePictureUrl: profilePictureUrl
        )
    }

    static func convert(user: User) -> [String: Any] {
        [
            DatabaseConstant.User.id: user.id,
            DatabaseConstant.User.name: user.name,
            DatabaseConstant.User.profilePictureUrl: user.profilePictureUrl ?? ""
        ]

    }
}
