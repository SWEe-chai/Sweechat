import SwiftUI
import Combine
import os

class MessageViewModel: ObservableObject {
    private var message: Message
    private var sender: User
    private var isSenderCurrentUser: Bool
    var subscriber: AnyCancellable?

    // MARK: IDs
    var id: String {
        message.id.val
    }

    var parentId: String? {
        message.parentId
    }

    // MARK: Messsage Bubble Properties
    var foregroundColor: Color {
        isSenderCurrentUser ? .white : .black
    }
    var backgroundColor: Color {
        isSenderCurrentUser ? ColorConstant.primary : ColorConstant.light.opacity(0.25)
    }
    var isRightAlign: Bool {
        isSenderCurrentUser
    }
    var messageContentType: MessageContentType {
        MessageContentType.convert(messageType: message.type)
    }
    var senderName: String {
        sender.name
    }

    init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.message = message
        self.sender = sender
        self.isSenderCurrentUser = isSenderCurrentUser
    }

    // MARK: Message Reply
    /// The content shown when replying to messages
    func previewContent() -> String {
        os_log("previewContent() in MessageViewModel called. Did you forget to implement in a subclass?")
        return "Message"
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
