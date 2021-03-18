//
//  ChatRoomAdapter.swift
//  Sweechat
//
//  Created by Christian James Welly on 18/3/21.
//

import Foundation
import FirebaseFirestore

class ChatRoomAdapter {
    static func convert(document: QueryDocumentSnapshot) -> ChatRoom? {
        let data = document.data()

        guard let id = data[DatabaseConstant.ChatRoom.id] as? String else {
            return nil
        }

        return ChatRoom(id: id)
    }

    static func convert(chatRoom: ChatRoom) -> [String: Any] {
        [
            DatabaseConstant.ChatRoom.id: chatRoom.id
        ]
    }
}
