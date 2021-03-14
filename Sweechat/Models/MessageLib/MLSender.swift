//
//  Sender.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

struct MLSender {
    var id: UUID
    var displayName: String

    init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}
