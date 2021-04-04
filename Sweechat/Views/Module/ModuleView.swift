//
//  ModuleView.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import SwiftUI

struct ModuleView: View {
    @ObservedObject var viewModel: ModuleViewModel
    @State private var showingCreateChatRoom = false
    @State private var isModuleSettingsOpened = false

    var body: some View {
        VStack {
            Text("Chatrooms in \(viewModel.text)")
            ForEach(viewModel.chatRoomViewModels) { chatRoomViewModel in
                NavigationLink(
                    destination:
                        LazyNavView(
                            ChatRoomViewFactory.makeView(
                                        viewModel: chatRoomViewModel))) {
                    ChatRoomItemView(viewModel: chatRoomViewModel)
                }
            }
            NavigationLink("",
                           destination: ModuleInformation(viewModel: viewModel),
                           isActive: $isModuleSettingsOpened)
        }
        .toolbar {
            HStack {
                Button(action: {
                    showingCreateChatRoom.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                }
                Button(action: {
                    isModuleSettingsOpened.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showingCreateChatRoom) {
            CreateChatRoomView(viewModel: viewModel.createChatRoomViewModel,
                               isShowing: $showingCreateChatRoom)
        }
        .navigationTitle(Text(viewModel.text))
    }
}
