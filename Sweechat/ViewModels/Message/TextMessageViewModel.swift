//
//  TextMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Combine

class TextMessageViewModel: MessageViewModel {
    @Published var text: String

    // MARK: Initialization

    init(message: Message, sender: User, currentUserId: Identifier<User>) {
        self.text = message.content.toString()
        super.init(message: message, sender: sender, currentUserId: currentUserId, isEditable: true)

        subscribers.append(message.subscribeToContent { content in
            self.text = content.toString()
            super.objectWillChange.send()
        })
    }

    override func previewContent() -> String {
        text
    }
}
