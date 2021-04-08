class ChatRoomPersistence {
    var userId: String
    var chatRoomId: String
    var persistence: Persistence?

    init(userId: String, chatRoomId: String) {
        self.userId = userId
        self.chatRoomId = chatRoomId
    }
}
