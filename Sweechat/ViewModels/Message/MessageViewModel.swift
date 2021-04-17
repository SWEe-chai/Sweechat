import SwiftUI
import Combine
import os

class MessageViewModel: ObservableObject {
    weak var delegate: MessageActionsViewModelDelegate?

    let isEditable: Bool
    let message: Message
    var subscribers: [AnyCancellable] = []

    @Published var likesCount: Int

    private let sender: User
    private let currentUserId: Identifier<User>

    // MARK: IDs

    var id: String {
        message.id.val
    }

    var parentId: String? {
        message.parentId?.val
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

    var isCurrentUserLiking: Bool {
        message.likers.contains(currentUserId)
    }

    var isSenderCurrentUser: Bool {
        sender.id == currentUserId
    }

    var profilePictureUrl: String? {
        sender.profilePictureUrl
    }

    // MARK: Initialization

    init(message: Message, sender: User, currentUserId: Identifier<User>, isEditable: Bool) {
        self.message = message
        self.sender = sender
        self.currentUserId = currentUserId
        self.isEditable = isEditable
        self.likesCount = message.likers.count
        subscribers.append(message.subscribeToLikers { userIdSet in
            self.likesCount = userIdSet.count
        })
    }

    /// The content shown when previewing messages
    func previewContent() -> String {
        os_log("previewContent() in MessageViewModel called. Did you forget to implement in a subclass?")
        return "Message"
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
