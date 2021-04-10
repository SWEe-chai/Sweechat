//
//  TextMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation

class TextMessageViewModel: MessageViewModel {
    @Published var text: String

    init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.text = message.content.toString()
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser, isEditable: true)

        subscriber = message.subscribeToContent { content in
            self.text = message.content.toString()
        }
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        // TODO: Might trim for long messages
        text
    }
}
