//
//  MessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

protocol MessageFacade {
    static var db: Firestore { get }
    static var reference: DocumentReference? { get }

    static func convert(document: QueryDocumentSnapshot) -> Message?
}
