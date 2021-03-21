//
//  ChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

import FirebaseFirestore

protocol ChatRoomFacade {
    var delegate: ChatRoomFacadeDelegate? { get set }
    func save(_ message: Message)
}
