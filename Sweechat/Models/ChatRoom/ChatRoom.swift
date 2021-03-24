//
//  ChatRoom.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//
import Combine
import Foundation

class ChatRoom: ObservableObject {
    var id: String
    var name: String
    var profilePictureUrl: String?
    @Published var messages: [Message] {
        willSet {
            objectWillChange.send()
        }
    }
    private var chatRoomFacade: ChatRoomFacade
    let permissions: ChatRoomPermissionBitmask

    init(id: String, name: String, profilePictureUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.messages = []
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

//    init(id: String, name: String, profilePictureUrl: String? = nil, messages: [Message]) {
//        self.id = id
//        self.name = name
//        self.profilePictureUrl = profilePictureUrl
//        self.messages = messages
//        self.permissions = ChatRoomPermission.none
//        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
//        chatRoomFacade.delegate = self
//    }

    func storeMessage(message: Message) {
        self.chatRoomFacade.save(message)
    }
}

// MARK: ChatRoomFacadeDelegate
extension ChatRoom: ChatRoomFacadeDelegate {
    func insert(message: Message) {
        guard !self.messages.contains(message) else {
            return
        }
        self.messages.append(message)
        self.messages.sort(by: { $0.creationTime < $1.creationTime })
    }

    func insertAll(messages: [Message]) {
        let newMessages = messages.sorted(by: { $0.creationTime < $1.creationTime })
        self.messages = newMessages
    }
}

extension ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
