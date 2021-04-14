//
//  NotificationMetadata.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/4/21.
//

import Combine

class NotificationMetadata {
    @Published var isFromNotif: Bool
    var directChatRoomId: String
    var directModuleId: String

    init(isFromNotif: Bool, directModuleId: String, directChatRoomId: String) {
        print("HOW MANY TIMES IS THIS CALLED")
        self.isFromNotif = isFromNotif
        self.directModuleId = directModuleId
        self.directChatRoomId = directChatRoomId
    }

    init() {
        print("HOW MANY TIMES IS THIS CALLED 2")
        self.isFromNotif = false
        self.directModuleId = ""
        self.directChatRoomId = ""
    }

    func subscribeToIsFromNotif(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $isFromNotif.sink(receiveValue: function)
    }
}
