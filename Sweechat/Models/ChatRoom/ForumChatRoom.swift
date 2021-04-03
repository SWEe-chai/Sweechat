import Combine

class ForumChatRoom: ChatRoom {
    @Published var posts: [Message] = []
    @Published var replies: [Message] = []

    override init(id: String,
                  name: String,
                  ownerId: String,
                  currentUser: User,
                  currentUserPermission: ChatRoomPermissionBitmask,
                  profilePictureUrl: String? = nil) {
        assert(ChatRoomPermission.canRead(permission: currentUserPermission)
                && ChatRoomPermission.canWrite(permission: currentUserPermission),
               "Assertion failed, forum user cannot read write")
        super.init(id: id,
                   name: name,
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: currentUserPermission,
                   profilePictureUrl: profilePictureUrl)
    }

    init(name: String,
         members: [User],
         currentUser: User,
         profilePictureUrl: String? = nil) {
        super.init(name: name,
                   members: members,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.all, // Creator gets all permissions
                   profilePictureUrl: profilePictureUrl)
    }

    func subscribeToPosts(function: @escaping ([Message]) -> Void) -> AnyCancellable {
        $posts.sink(receiveValue: function)
    }

    func subscribeToReplies(function: @escaping ([Message]) -> Void) -> AnyCancellable {
        $replies.sink(receiveValue: function)
    }

    override func insert(message: Message) {
        super.insert(message: message)

        guard let addedMessage = self.messages.first(where: { $0.id == message.id }),
              message.type != .keyExchange else {
            // Only try to insert if it's not key exchange and of type key exchange
            return
        }

        if addedMessage.parentId == nil && !posts.contains(addedMessage) {
            posts.append(addedMessage)
        }

        if addedMessage.parentId != nil && !replies.contains(addedMessage) {
            replies.append(addedMessage)
        }
    }

    override func insertAll(messages: [Message]) {
        super.insertAll(messages: messages)

        posts = self.messages.filter { $0.parentId == nil && $0.type != .keyExchange }
        replies = self.messages.filter { $0.parentId != nil }
    }

    override func remove(message: Message) {
        // TODO: Implement remove not in FE yet so it's fine
        super.remove(message: message)
    }

    override func update(message: Message) {
        // TODO: Implement update not in FE yet so it's fine
        super.update(message: message)
    }
}
