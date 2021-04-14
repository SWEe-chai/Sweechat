//
//  NotificationMetadata.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/4/21.
//

struct NotificationMetadata {
    var isFromNotif: Bool
    var directChatRoomId: String
    var directModuleId: String
    
    init(isFromNotif: Bool, directModuleId: String, directChatRoomId: String) {
        self.isFromNotif = isFromNotif
        self.directModuleId = directModuleId
        self.directChatRoomId = directChatRoomId
    }
    
    init() {
        self.isFromNotif = false
        self.directModuleId = ""
        self.directChatRoomId = ""
    }
}
