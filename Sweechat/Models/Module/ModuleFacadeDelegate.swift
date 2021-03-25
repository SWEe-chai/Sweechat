//
//  ModuleFacadeDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

protocol ModuleFacadeDelegate: AnyObject {
    func insert(chatRoom: ChatRoom)
    func insert(user: User)
    func insertAll(chatRooms: [ChatRoom])
    func insertAll(users: [User])
}
