//
//  ModuleFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

protocol ModuleFacade {
    var delegate: ModuleFacadeDelegate? { get set }
    func save(chatRoom: ChatRoom)
    func save(user: User)
}
