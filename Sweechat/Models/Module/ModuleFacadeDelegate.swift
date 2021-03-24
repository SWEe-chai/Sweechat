//
//  ModuleFacadeDelegate.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

protocol ModuleFacadeDelegate: AnyObject {
    func insert(chatRoom: ChatRoom)
    func insertAll(chatRooms: [ChatRoom])
}
