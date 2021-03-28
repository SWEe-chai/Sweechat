//
//  MessageViewFactory.swift
//  Sweechat
//
//  Created by Christian James Welly on 28/3/21.
//
import SwiftUI

struct MessageViewFactory {
    static func makeView(viewModel: MessageViewModel) -> some View {
        switch viewModel.type {
        case .text:
            return AnyView(TextMessageView(viewModel: viewModel))
        case .image:
            return AnyView(ImageMessageView(viewModel: viewModel))
        default:
            return AnyView(TextMessageView(viewModel: viewModel))
        }
    }
}
