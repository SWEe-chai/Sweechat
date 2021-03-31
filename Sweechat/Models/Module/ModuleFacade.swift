//
//  ModuleFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 24/3/21.
//

protocol ModuleFacade {
    var delegate: ModuleFacadeDelegate? { get set }
    func save(chatRoom: ChatRoom,
              userPermissions: [UserPermissionPair])
    func save(user: User)
}
