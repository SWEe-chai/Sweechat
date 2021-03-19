//
//  MessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

protocol MessageFacade {
    var db: Firestore { get }
    var reference: DocumentReference? { get }

    static func convert(document: DocumentSnapshot) -> MessageRepresentation?
}
