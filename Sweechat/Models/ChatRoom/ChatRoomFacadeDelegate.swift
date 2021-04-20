/**
 An interface through which the server communicates with the calling `ChatRoom` instance.
 */
protocol ChatRoomFacadeDelegate: AnyObject {
    func insert(message: Message)
    func insertAll(messages: [Message])
    func handleKeyExchangeMessages(keyExchangeMessages: [Message]) -> Bool
    func update(message: Message)
    func remove(message: Message)
    func insert(member: User)
    func remove(member: User)
    func insertAll(members: [User])
    func update(chatRoom: ChatRoom)
}
