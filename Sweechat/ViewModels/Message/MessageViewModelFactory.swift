//
//  MessageViewModelFactory.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

struct MessageViewModelFactory {
    static func makeViewModel(
        message: Message,
        sender: User,
        delegate: MediaMessageViewModelDelegate,
        isSenderCurrentUser: Bool) -> MessageViewModel? {
        switch message.type {
        case .text:
            return TextMessageViewModel(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)
        case .image:
            return ImageMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                isSenderCurrentUser: isSenderCurrentUser)
        case .video:
            return VideoMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                isSenderCurrentUser: isSenderCurrentUser)
        default:
            // This means that the type of the message is not supported by the ViewModel
            // And thus the view
            return nil
        }
    }
}
