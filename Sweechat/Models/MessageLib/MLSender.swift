//
//  Sender.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

struct MLSender {
    var id: String
    var displayName: String
    
    init(id: String) {
        self.id = id
        self.displayName = "sender"
    }
    
    init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}
