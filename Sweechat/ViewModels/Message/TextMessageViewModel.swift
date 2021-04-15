//
//  TextMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation

class TextMessageViewModel: MessageViewModel {
    @Published var text: String

    init(message: Message, sender: User, currentUserId: Identifier<User>) {
        self.text = message.content.toString()
        super.init(message: message, sender: sender, currentUserId: currentUserId, isEditable: true)

        subscribers.append(message.subscribeToContent { content in
            self.text = content.toString()
            super.objectWillChange.send()
        })
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        // TODO: Might trim for long messages
        text
    }
}
