//
//  ChatRoomFacadeDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//

protocol ChatRoomFacadeDelegate: AnyObject {
    func insert(message: Message)
    func insertAll(messages: [Message])
    func getUser(userId: String) -> User
}
