/**
 An interface through which the server communicates with the calling `Module` instance.
 */
protocol ModuleFacadeDelegate: AnyObject {
    func insert(chatRoom: ChatRoom)
    func remove(chatRoom: ChatRoom)
    func insert(user: User)
    func remove(user: User)
    func insertAll(chatRooms: [ChatRoom])
    func insertAll(users: [User])
    func update(module: Module)
}
