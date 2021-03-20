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
    @Published var messages: [Message] {
        willSet {
            objectWillChange.send()
        }
    }
    private var chatRoomFacade: FirebaseChatRoomFacade
    let permissions: ChatRoomPermissionBitmask

    init() {
        self.id = UUID().uuidString
        self.messages = []
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

    init(id: String) {
        self.id = id
        self.messages = []
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

    init(id: String, messages: [Message]) {
        self.id = id
        self.messages = messages
        self.permissions = ChatRoomPermission.none
        self.chatRoomFacade = FirebaseChatRoomFacade(chatRoomId: id)
        chatRoomFacade.delegate = self
    }

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
}
