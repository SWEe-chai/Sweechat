//
//  Module.swift
//  Sweechat
//
//  Created by Christian James Welly on 18/3/21.
//

struct Module {
    let id: String
    let name: String
    let modulePictureURL: String?

    init(id: String, name: String, modulePictureURL: String = "") {
        self.id = id
        self.name = name
        self.modulePictureURL = modulePictureURL
    }
}
