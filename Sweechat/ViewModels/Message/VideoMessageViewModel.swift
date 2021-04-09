//
//  VideoMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

import Foundation

class VideoMessageViewModel: MessageViewModel {
    private var onlineUrl: String
    @Published var url: URL?
    weak var delegate: MediaMessageViewModelDelegate?

    init(message: Message,
         sender: User,
         delegate: MediaMessageViewModelDelegate,
         isSenderCurrentUser: Bool) {
        self.delegate = delegate
        self.onlineUrl = message.content.toString()
        super.init(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)

        subscriber = message.subscribeToContent { newContent in
            if newContent.toString() != self.onlineUrl {
                self.onlineUrl = newContent.toString()
            }
        }

        self.delegate?.fetchVideoLocalUrl(fromUrl: message.content.toString()) { localUrlString in
            guard let localUrlString = localUrlString else {
                return
            }
            DispatchQueue.main.async {
                self.url = URL(fileURLWithPath: localUrlString)
                super.objectWillChange.send()
            }
        }
    }

    // MARK: Message Reply
    override func previewContent() -> String {
        "Video"
    }
}
