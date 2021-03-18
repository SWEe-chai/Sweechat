//
//  Module.swift
//  Sweechat
//
//  Created by Christian James Welly on 18/3/21.
//

struct Module {
    let id: String
    let name: String
    var chatRooms: [ChatRoom]
    let modulePictureURL: String?

    init(id: String, name: String, modulePictureURL: String = "") {
        self.id = id
        self.name = name
        chatRooms = []
        self.modulePictureURL = modulePictureURL
    }
}
