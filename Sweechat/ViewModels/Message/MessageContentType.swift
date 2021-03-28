//
//  MessageContentType.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//

enum MessageContentType {
    case text, media, unsupported

    static func convert(messageType: MessageType) -> MessageContentType {
        switch messageType {
        case .text:
            return .text
        case .image:
            return .media
        default:
            return .unsupported
        }
    }
}
