//
//  ImageMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

import Foundation
import Combine

class ImageMessageViewModel: MessageViewModel {
    var mediaData: ImageDataViewModel

    init(message: Message,
         sender: User,
         delegate: MediaMessageViewModelDelegate,
         currentUserId: UserId) {
        self.mediaData = ImageDataViewModel(
            urlString: message.content.toString(),
            delegate: delegate)
        super.init(message: message, sender: sender, currentUserId: currentUserId, isEditable: false)

        subscribers.append(message.subscribeToContent { newContent in
            self.mediaData.updateUrl(url: newContent.toString())
        })
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        "Image"
    }
}
