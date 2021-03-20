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
        VStack {
            Text(viewModel.text)
            Button(action: viewModel.tappedOnChatRoom, label: {
                Text("Chat room")
            })
        }
    }
}
