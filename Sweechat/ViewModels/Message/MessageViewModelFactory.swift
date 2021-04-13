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
        currentUserId: Identifier<User>) -> MessageViewModel? {
        switch message.type {
        case .text:
            return TextMessageViewModel(
                message: message,
                sender: sender,
                currentUserId: currentUserId)
        case .image:
            return ImageMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                currentUserId: currentUserId)
        case .video:
            return VideoMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                currentUserId: currentUserId)
        default:
            // This means that the type of the message is not supported by the ViewModel
            // And thus the view
            return nil
        }
    }
}
