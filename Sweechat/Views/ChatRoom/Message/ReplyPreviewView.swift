//
//  ReplyPreviewView.swift
//  Sweechat
//
//  Created by Christian James Welly on 2/4/21.
//

import SwiftUI

struct ReplyPreviewView: View {
    var message: MessageViewModel
    var borderColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(message.senderName)
                .font(FontConstant.MessageReplySender)
            Text(message.previewContent())
                .font(FontConstant.MessageReplyText)
                .lineLimit(1)
        }
        .padding([.leading, .trailing], 10)
        .border(width: 2, edges: [.leading, .trailing], color: borderColor)
        .fixedSize(horizontal: false, vertical: true) // So that it does not stretch vertically
    }
}
