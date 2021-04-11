import SwiftUI
import Combine
import os

class MessageViewModel: ObservableObject {
    private var sender: User
    private var isSenderCurrentUser: Bool
    weak var delegate: MessageActionsViewModelDelegate?
    var isEditable: Bool
    var message: Message
    var subscribers: [AnyCancellable] = []

    // MARK: IDs
    var id: String {
        message.id
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
    @Published var likesCount: Int

    init(message: Message, sender: User, isSenderCurrentUser: Bool, isEditable: Bool) {
        self.message = message
        self.sender = sender
        self.isSenderCurrentUser = isSenderCurrentUser
        self.isEditable = isEditable
        self.likesCount = message.likers.count
        subscribers.append(message.subscribeToLikers { userIdSet in
            self.likesCount = userIdSet.count
        })
    }

    // MARK: Message Reply
    /// The content shown when replying to messages
    func previewContent() -> String {
        os_log("previewContent() in MessageViewModel called. Did you forget to implement in a subclass?")
        return "Message"
    }

    func edit() {
        delegate?.edit(messageViewModel: self)
    }

    func delete() {
        delegate?.delete(messageViewModel: self)
    }

    func toggleLike() {
        delegate?.toggleLike(messageViewModel: self)
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
