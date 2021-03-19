import Foundation
import FirebaseFirestore

class FirebaseUserFacade: UserFacade {
    weak var delegate: UserFacadeDelegate?

    private var db = Firestore.firestore()
    private var userId: String!
    private var reference: DocumentReference?
    private var messageListener: ListenerRegistration?

    func loginAsUser(withDetails details: UserDetails) {
        userId = details.id
        db.collection(DatabaseConstant.Collection.users).document(userId).getDocument { document, _ in
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
        db.collection(DatabaseConstant.Collection.users).document(details.id).setData([
                    DatabaseConstant.User.id: details.id,
                    DatabaseConstant.User.name: details.name,
                    DatabaseConstant.User.profilePictureURL: details.profilePictureURL
        ], completion: { _ in
            self.setUpConnectionAsUser()
        })
    }

    private func setUpConnectionAsUser() {
        reference = db.collection(DatabaseConstant.Collection.users).document(userId)
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  let data = snapshot.data() else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            guard let id = data[DatabaseConstant.User.id] as? String,
                  let name = data[DatabaseConstant.User.name] as? String,
                  let profilePictureURL = data[DatabaseConstant.User.profilePictureURL] as? String else {
                print("Error reading data update for user")
                return
            }
            let details = UserDetails(id: id,
                                      name: name,
                                      profilePictureURL: profilePictureURL,
                                      isLoggedIn: true)
            self.delegate?.updateUserData(withDetails: details)
        }
    }
}