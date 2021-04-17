//
//  VideoMessageViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

class VideoMessageViewModel: MessageViewModel {
    let localFileViewModel: LocalFileViewModel

    // MARK: Initialization

    init(message: Message,
         sender: User,
         delegate: MediaMessageViewModelDelegate,
         currentUserId: Identifier<User>) {
        self.localFileViewModel = LocalFileViewModel(onlineUrlString: message.content.toString(),
                                                     delegate: delegate)
        super.init(message: message, sender: sender, currentUserId: currentUserId, isEditable: false)

        subscribers.append(message.subscribeToContent { newContent in
            self.localFileViewModel.updateOnlineUrl(newUrl: newContent.toString())
        })
    }

    override func previewContent() -> String {
        "Video"
    }
}
