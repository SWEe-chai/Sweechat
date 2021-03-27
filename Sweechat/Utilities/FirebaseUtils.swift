//
//  FirebaseUtils.swift
//  Sweechat
//
//  Created by Christian James Welly on 27/3/21.
//

import Foundation
import FirebaseFirestore

struct FirebaseUtils {
    static func getEnvironmentReference(_ db: Firestore) -> DocumentReference {
        db.collection(DatabaseConstant.Collection.environmentCollection)
            .document(DatabaseConstant.Collection.environmentDocument)
    }
}
