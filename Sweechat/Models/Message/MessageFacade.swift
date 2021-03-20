//
//  MessageFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

protocol MessageFacade {
    static func convert(document: DocumentSnapshot) -> MessageRepresentation?
}
