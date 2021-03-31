//
//  MessageViewModelFactory.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

struct MessageViewModelFactory {
    static func makeViewModel(message: Message, sender: User, isSenderCurrentUser: Bool) -> MessageViewModel {
        switch message.type {
        case .text:
            return TextMessageViewModel(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)
        case .image:
            return ImageMessageViewModel(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)
        case .video:
            return VideoMessageViewModel(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)
        default:
            // TODO: Perhaps we can use a placeholder view model that will always return some
            // content for a currently-unsupported type
            return MessageViewModel(message: message, sender: sender, isSenderCurrentUser: isSenderCurrentUser)
        }
    }
}
