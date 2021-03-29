//
//  MediaMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation

class MediaMessageViewModel: MessageViewModel {
    @Published var url: String

    override init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.url = message.content.toString()
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { content in
            self.url = message.content.toString()
        }
    }
}
