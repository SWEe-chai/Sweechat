//
//  ChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

protocol ChatRoomFacade {
    var db: Firestore { get }
    var reference: CollectionReference? { get }

    var delegate: ChatRoomFacadeDelegate? { get set }
}
