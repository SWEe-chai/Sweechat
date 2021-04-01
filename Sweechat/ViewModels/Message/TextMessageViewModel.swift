//
//  TextMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation

class TextMessageViewModel: MessageViewModel {
    @Published var text: String

    override init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.text = message.content.toString()
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { content in
            self.text = message.content.toString()
        }
    }
}
