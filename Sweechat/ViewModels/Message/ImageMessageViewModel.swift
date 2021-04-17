//
//  ImageMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

class ImageMessageViewModel: MessageViewModel {
    let mediaData: ImageDataViewModel

    // MARK: Initialization

    init(message: Message,
         sender: User,
         delegate: MediaMessageViewModelDelegate,
         currentUserId: Identifier<User>) {
        self.mediaData = ImageDataViewModel(urlString: message.content.toString(),
                                            delegate: delegate)
        super.init(message: message, sender: sender, currentUserId: currentUserId, isEditable: false)

        subscribers.append(message.subscribeToContent { newContent in
            self.mediaData.updateUrl(url: newContent.toString())
        })
    }

    override func previewContent() -> String {
        "Image"
    }
}
