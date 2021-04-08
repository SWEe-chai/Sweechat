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
        // TODO: Load correct url 
        self.mediaData = MediaDataViewModel(
//            url: message.content.toString()
            url: "https://miro.medium.com/max/1200/1*mk1-6aYaf_Bes1E3Imhc0A.jpeg",
            delegate: delegate)
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { _ in
//            self.mediaData.updateUrl(url: message.content.toString())
        }
    }

    // TODO: REMOVE THIS FUNCTION AFTER TESTS
    func swapUrl() {
        self.mediaData.updateUrl(
            url: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__340.jpg")
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        "Image"
    }
}
