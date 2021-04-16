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
    private var defaultIsFromNotifValue = false
    private var defaultDirectModuleIdValue = ""
    private var defaultDirectChatRoomIdValue = ""

    init(isFromNotif: Bool, directModuleId: String, directChatRoomId: String) {
        self.isFromNotif = isFromNotif
        self.directModuleId = directModuleId
        self.directChatRoomId = directChatRoomId
    }

    init() {
        self.isFromNotif = defaultIsFromNotifValue
        self.directModuleId = defaultDirectModuleIdValue
        self.directChatRoomId = defaultDirectChatRoomIdValue
    }

    func subscribeToIsFromNotif(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $isFromNotif.sink(receiveValue: function)
    }

    func reset() {
        self.isFromNotif = defaultIsFromNotifValue
        self.directModuleId = defaultDirectModuleIdValue
        self.directChatRoomId = defaultDirectChatRoomIdValue
    }
}
