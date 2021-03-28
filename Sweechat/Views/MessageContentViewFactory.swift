//
//  MessageViewFactory.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//
import SwiftUI

struct MessageContentViewFactory {
    static func makeView(viewModel: MessageViewModel) -> some View {
        switch viewModel {
        case let textMessageViewModel as TextMessageViewModel:
            return AnyView(TextMessageContentView(viewModel: textMessageViewModel))
        case let mediaMessageViewModel as MediaMessageViewModel:
            return AnyView(ImageMessageContentView(viewModel: mediaMessageViewModel))
        default:
            return AnyView(UnsupportedMessageContentView())
        }
    }
}
