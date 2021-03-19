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
        db.collection("users").document(userId).getDocument { document, _ in
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
        db.collection("users").document(details.id).setData([
                    "id": details.id,
                    "name": details.name,
                    "profilePictureURL": details.profilePictureURL
        ], completion: { _ in
            self.setUpConnectionAsUser()
        })
    }

    private func setUpConnectionAsUser() {
        reference = db.collection("users").document(userId)
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  let data = snapshot.data() else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            guard let id = data["id"] as? String,
                  let name = data["name"] as? String,
                  let profilePictureURL = data["profilePictureURL"] as? String else {
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
