import SwiftUI

class MessageViewModel {
    private var message: Message
    private var isCurrentUser: Bool

    var content: String
    var foregroundColor: Color {
        isCurrentUser ? .white : .black
    }
    var backgroundColor: Color {
        isCurrentUser ? .blue : Color.gray.opacity(0.25)
    }
    var isRightAlign: Bool {
        isCurrentUser
    }
    var title: String? {
        isCurrentUser ? nil : message.sender.name
    }

    init(message: Message, isCurrentUser: Bool) {
        self.message = message
        self.content = message.content
        self.isCurrentUser = isCurrentUser
    }
}

extension MessageViewModel: Identifiable {

}
