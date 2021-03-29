import SwiftUI
import Combine
import os

class MessageViewModel: ObservableObject {
    private var message: Message
    private var sender: User
    private var isSenderCurrentUser: Bool
    var subscriber: AnyCancellable?

    var foregroundColor: Color {
        isSenderCurrentUser ? .white : .black
    }
    var backgroundColor: Color {
        isSenderCurrentUser ? .blue : Color.gray.opacity(0.25)
    }
    var isRightAlign: Bool {
        isSenderCurrentUser
    }
    var title: String? {
        isSenderCurrentUser ? nil : sender.name
    }
    var messageContentType: MessageContentType {
        MessageContentType.convert(messageType: message.type)
    }

    init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.message = message
        self.sender = sender
        self.isSenderCurrentUser = isSenderCurrentUser
    }
}

// MARK: Hashable
extension MessageViewModel: Hashable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs.message.id == rhs.message.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(message.id)
    }
}