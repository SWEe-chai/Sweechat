//
//  UserAdapter.swift
//  Sweechat
//
//  Created by Agnes Natasya on 18/3/21.
//

import Firebase
import FirebaseFirestore

class UserAdapter {
    static func getUserDetails(id: String) -> User? {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(id)
        var user = User()
        docRef.getDocument { document, _ in
            if let document = document, document.exists {
                let data = document.data()
                guard let id = data?[DatabaseConstant.User.id] as? String,
                      let name = data?[DatabaseConstant.User.name] as? String,
                      let photoUrl = data?[DatabaseConstant.User.photo] as? String else {
                return
                }
                user = User(id: id, name: name, photoUrl: photoUrl)
            } else {
                print("Document does not exist")
            }
        }
        return user

    }
}
