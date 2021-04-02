//
//  ReplyPreviewView.swift
//  Sweechat
//
//  Created by Christian James Welly on 2/4/21.
//

import SwiftUI

struct ReplyPreviewView: View {
   var message: MessageViewModel

   var body: some View {
       VStack(alignment: .leading) {
           Text(message.senderName)
               .fontWeight(.bold)
           Text(message.previewContent())
               .lineLimit(1)
       }
       .padding(.leading, 10)
       .font(.caption)
       .border(width: 2, edges: [.leading], color: Color.gray)
       // So that it does not stretch vertically
       .fixedSize(horizontal: false, vertical: true)
   }
}
