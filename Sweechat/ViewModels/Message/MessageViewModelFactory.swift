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
        currentUserId: UserId,
        messageIdToMessages: [Identifier<Message>: Message]) -> MessageViewModel? {
        let parentMessage = messageIdToMessages[message.parentId ?? ""]
        switch message.type {
        case .text:
            return TextMessageViewModel(
                message: message,
                sender: sender,
                currentUserId: currentUserId,
                parentMessage: parentMessage)
        case .image:
            return ImageMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                currentUserId: currentUserId,
                parentMessage: parentMessage)
        case .video:
            return VideoMessageViewModel(
                message: message,
                sender: sender,
                delegate: delegate,
                currentUserId: currentUserId,
                parentMessage: parentMessage)
        default:
            // This means that the type of the message is not supported by the ViewModel
            // And thus the view
            return nil
        }
    }
}
