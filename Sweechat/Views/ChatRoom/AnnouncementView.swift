//
//  AnnouncementView.swift
//  Sweechat
//
//  Created by Hai Nguyen on 1/4/21.
//

import SwiftUI

struct AnnouncementView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var body: some View {
        MessagesScrollView(viewModel: viewModel)
    }
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(
            viewModel:
                ChatRoomViewModel(
                    chatRoom: ChatRoom(
                        id: "chatRoomId",
                        name: "Announcements",
                        currentUser: User(id: "Hello", name: "Happy boi"),
                        permissions: ChatRoomPermission.all),
                    user: User(id: "Hello", name: "Happy boi")))
    }
}
