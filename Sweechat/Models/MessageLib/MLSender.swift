//
//  Sender.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

struct MLSender {
    var id: String
    var name: String

    init(id: String) {
        self.id = id
        self.name = "sender"
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
