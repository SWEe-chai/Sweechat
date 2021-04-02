//
//  VideoMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

import Foundation

class VideoMessageViewModel: MessageViewModel {
    @Published var url: URL?

    override init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.url = URL(string: message.content.toString())
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { content in
            self.url = URL(string: content.toString())
        }
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        "Video"
    }
}
