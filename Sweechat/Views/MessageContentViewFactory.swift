//
//  MessageViewFactory.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//
import SwiftUI

struct MessageContentViewFactory {
    static func makeView(viewModel: MessageViewModel) -> some View {
        switch viewModel.type {
        case .text:
            return AnyView(TextMessageContentView(viewModel: viewModel))
        case .image:
            return AnyView(ImageMessageContentView(viewModel: viewModel))
        default:
            return AnyView(TextMessageContentView(viewModel: viewModel))
        }
    }
}
