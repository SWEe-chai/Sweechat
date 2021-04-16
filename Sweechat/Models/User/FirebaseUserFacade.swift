import FirebaseFirestore
import FirebaseInstanceID
import os

class FirebaseUserFacade: UserFacade {
    weak var delegate: UserFacadeDelegate?
    private var userId: Identifier<User>

    private var db = Firestore.firestore()
    private var usersReference: CollectionReference
    private var reference: DocumentReference?
    private var userListener: ListenerRegistration?
    private var publicKeyBundlesReference: CollectionReference

    init(userId: Identifier<User>) {
        self.userId = userId
        self.usersReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.users)
        self.publicKeyBundlesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.publicKeyBundles)
    }

    func loginAndListenToUser(_ user: User) {
        userId = user.id
        self.usersReference.document(userId.val).getDocument { document, _ in
            guard let document = document,
                  document.exists else {
                // In this case user is a new user
                self.addUser(user)
                self.uploadPublicKeyBundleData(for: user)
                return
            }
            self.setUpConnectionAsUser()
        }
    }

    private func addUser(_ user: User) {
        self.usersReference
            .document(user.id.val)
            .setData(
                FirebaseUserAdapter
                    .convert(user: user), completion: { _ in
                        self.setUpConnectionAsUser()
                    }
            )
    }

    private func uploadPublicKeyBundleData(for user: User) {
        if let publicKeyBundleData = user.getPublicKeyBundleData() {
            self.publicKeyBundlesReference
                .document(user.id.val)
                .setData(FirebaseUserAdapter.convert(userId: user.id, publicKeyBundleData: publicKeyBundleData))
        }
    }

    private func setUpConnectionAsUser() {
        if userId.val.isEmpty {
            os_log("Error loading user: User id is empty")
            return
        }
        if (FcmJsonStorageManager.load()) == "" {
            os_log("No FCM token")
        }
        usersReference
            .document(userId.val)
            .setData([DatabaseConstant.User.token: FcmJsonStorageManager.load() ?? ""], merge: true)
        reference = usersReference
            .document(userId.val)
        userListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            self.delegate?.update(
                user: FirebaseUserAdapter.convert(document: snapshot)
            )
        }
    }
}
