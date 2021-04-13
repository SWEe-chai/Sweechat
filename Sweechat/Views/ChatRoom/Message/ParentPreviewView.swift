//
//  ReplyPreviewView.swift
//  Sweechat
//
//  Created by Christian James Welly on 2/4/21.
//

import SwiftUI

struct ParentPreviewView: View {
    var message: MessageViewModel
    var borderColor: Color
    var isEditPreview: Bool = false

    var headerText: String {
        isEditPreview ? "Edit Message" : message.senderName
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(headerText)
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
