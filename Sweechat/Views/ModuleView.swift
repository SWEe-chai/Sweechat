//
//  ModuleView.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import SwiftUI

struct ModuleView: View {
    @ObservedObject var viewModel: ModuleViewModel

    var body: some View {
        Text(viewModel.text)
        Button(action: viewModel.didTapChatRoomButton, label: {
            Text("Chat room")
        })
    }
}
