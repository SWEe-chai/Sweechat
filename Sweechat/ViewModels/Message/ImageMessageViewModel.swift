//
//  ImageMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation
import Combine

class ImageMessageViewModel: MessageViewModel {
    var mediaData: MediaDataViewModel

    init(message: Message,
         sender: User,
         delegate: MediaMessageViewModelDelegate,
         isSenderCurrentUser: Bool) {
        self.mediaData = MediaDataViewModel(
            url: message.content.toString(),
            delegate: delegate)
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { newContent in
            self.mediaData.updateUrl(url: newContent.toString())
        }
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        "Image"
    }
}
