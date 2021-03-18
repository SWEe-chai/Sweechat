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
            Text("Module name: \(viewModel.name)")
            Text("Chatrooms: ")
            ScrollView(.vertical) {
                ForEach(viewModel.module.chatRooms, id: \.self.id) { chatRoom in
                    VStack {
                        Text("Chatroom with id: \(chatRoom.id)")
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            viewModel.connectToFirebase()
        }
    }
}
