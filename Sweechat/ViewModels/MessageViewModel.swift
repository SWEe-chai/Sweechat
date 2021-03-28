import SwiftUI
import Combine
import os

class MessageViewModel: ObservableObject {
    @Published var message: Message
    private var sender: User
    private var isSenderCurrentUser: Bool
    var subscriber: AnyCancellable?

    @Published var content: String?
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
        parseContent(message.content)

        subscriber = message.subscribeToContent { content in
            self.parseContent(content)
        }
    }

    private func parseContent(_ content: Data) {
        switch message.type {
        case .text, .image:
            self.content = message.content.toString()
        default:
            self.content = "The message type: \(self.message.type.rawValue) is not implemented"
        }
    }
}

// MARK: Hashable
extension MessageViewModel: Hashable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs.message.id == rhs.message.id
            && lhs.content == rhs.content
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(message.id)
    }
}
