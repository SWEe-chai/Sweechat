//
//  ModuleView.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import SwiftUI

struct ModuleView: View {
    @ObservedObject var viewModel: ModuleViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCreateChatRoom = false
    @State private var isModuleSettingsOpened = false
    @State var isNavigationBarHidden: Bool = true
    @State private var chatRoomListType: ChatRoomListType = .groupChat

    var moduleSettingsToolbar: some View {
        HStack {
            Button(action: {
                showingCreateChatRoom.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(ColorConstant.white)
            }
            Button(action: {
                isModuleSettingsOpened.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(ColorConstant.white)
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(ColorConstant.white)
            }
        }
        .padding()
    }

    var moduleHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Chat Rooms").moduleHeaderFont().padding(.top, 10)
                Text("in \(viewModel.text)").moduleHeaderFont().padding(.bottom, 10)
            }
            Spacer()
            moduleSettingsToolbar
        }
        .padding(.horizontal, 30)
    }

    var hiddenSettingsNavLink: some View {
        NavigationLink("",
                       destination: ModuleInformation(
                        viewModel: viewModel,
                        isNavigationBarHidden: $isNavigationBarHidden
                       ),
                       isActive: $isModuleSettingsOpened)
            .hidden()
    }

    var chatRoomListTypeToolbar: some View {
        HStack {
            Spacer()
            ForEach(ChatRoomListType.allTypes(), id: \.self) { type in
                chatRoomTypeButton(type)
            }
            Spacer()
        }
    }

    func chatRoomTypeButton(_ type: ChatRoomListType) -> some View {
        Button(action: { chatRoomListType = type }) {
            Text(type.rawValue).font(FontConstant.ChatRoomTypeButton)
        }.opacity(chatRoomListType == type ? 1 : 0.5).padding(10).buttonStyle(PlainButtonStyle())
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("").lineLimit(nil)
            Text("").lineLimit(nil)
            moduleHeader
            VStack(alignment: .leading) {
                chatRoomListTypeToolbar
                ScrollView {
                    ForEach(viewModel.getChatRoomList(type: chatRoomListType)) { chatRoomViewModel in
                        Button(action: {
                            viewModel.currentChatRoomViewModel = chatRoomViewModel
                            viewModel.isRedirectToChatRoom = true
                        }) {
                            HStack {
                                ChatRoomItemView(viewModel: chatRoomViewModel)
                                Spacer()
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorConstant.base)
                )
                NavigationLink(
                    "",
                    destination: LazyNavView(
                        ChatRoomViewFactory.makeView(
                            viewModel: viewModel.currentChatRoomViewModel,
                            isNavigationBarHidden: $isNavigationBarHidden
                        )
                    ),
                    isActive: $viewModel.isRedirectToChatRoom
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorConstant.base)
                    .ignoresSafeArea(.all, edges: .bottom)
            )
            hiddenSettingsNavLink
        }
        .onAppear {
            isNavigationBarHidden = true
            viewModel.sortChatRooms()
        }
        .background(ColorConstant.primary.ignoresSafeArea())
        .sheet(isPresented: $showingCreateChatRoom) {
            CreateChatRoomView(viewModel: viewModel.createChatRoomViewModel,
                               isShowing: $showingCreateChatRoom,
                               moduleName: viewModel.text)
        }
        .navigationBarTitle("")
        .navigationBarHidden(isNavigationBarHidden)
    }
}

extension View {
    func moduleHeaderFont() -> some View {
        self.font(FontConstant.Heading1)
            .foregroundColor(ColorConstant.white)
    }
}
