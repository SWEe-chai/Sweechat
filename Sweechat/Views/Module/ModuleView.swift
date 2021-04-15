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

    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .leading, spacing: 0) {
                Text("").lineLimit(nil)
                Text("").lineLimit(nil)
                Text("").lineLimit(nil)
                Text("").lineLimit(nil)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Chat Rooms")
                            .font(FontConstant.Heading1)
                            .foregroundColor(ColorConstant.white)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        Text("in \(viewModel.text)")
                            .font(FontConstant.Heading1)
                            .foregroundColor(ColorConstant.white)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                    Spacer()
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
                .padding(.horizontal)
                VStack(alignment: .leading) {
                    ScrollView {
                        Text("").lineLimit(nil)
                        ForEach(viewModel.chatRoomViewModels) { chatRoomViewModel in
                            NavigationLink(
                                destination:
                                    LazyNavView(
                                        ChatRoomViewFactory.makeView(
                                            viewModel: chatRoomViewModel,
                                            isNavigationBarHidden: $isNavigationBarHidden
                                        )
                                    )
                            ) {
                                HStack {
                                    ChatRoomItemView(viewModel: chatRoomViewModel)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()
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
                            viewModel: viewModel.directChatRoomViewModel,
                            isNavigationBarHidden: $isNavigationBarHidden
                        )
                    ),
                    isActive: Binding<Bool>(
                        get: { viewModel.isDirectChatRoomLoaded },
                        set: { _ in viewModel.isDirectChatRoomLoaded = false }
                    )
                )
                .navigationBarHidden(false)

                NavigationLink("",
                               destination: ModuleInformation(
                                viewModel: viewModel,
                                isNavigationBarHidden: $isNavigationBarHidden
                               ),
                               isActive: $isModuleSettingsOpened
                )
                .navigationBarHidden(false)
            }
        }
        .onAppear {
            isNavigationBarHidden = true
        }
        .background(ColorConstant.primary)
        .sheet(isPresented: $showingCreateChatRoom) {
            CreateChatRoomView(viewModel: viewModel.createChatRoomViewModel,
                               isShowing: $showingCreateChatRoom)
        }
        .navigationBarTitle("")
        .navigationBarHidden(isNavigationBarHidden)
        .edgesIgnoringSafeArea(.all)
    }
}
