import SwiftUI

class MessageViewModel {
    private var message: Message
    private var sender: User
    private var isSenderCurrentUser: Bool

    var content: String
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

    init(message: Message, sender: User, isSenderCurrentUser: Bool) {
        self.message = message
        self.content = message.content
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
