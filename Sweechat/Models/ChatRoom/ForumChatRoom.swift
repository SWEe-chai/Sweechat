import Combine

class ForumChatRoom: ChatRoom {
    @Published var posts: [Message] = []
    @Published var postIdToReplies: [String: [Message]] = [:]

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

    func subscribeToPostIdToReplies(function: @escaping ([String: [Message]]) -> Void) -> AnyCancellable {
        $postIdToReplies.sink(receiveValue: function)
    }

    override func insert(message: Message) {
        super.insert(message: message)
        // After the insert we want to insert into posts
        if message.type == .keyExchange {
            return
        }
        guard let addedMessage = self.messages.first(where: { $0.id == message.id }) else {
            // Super logic did not add this message
            return
        }
        guard let parentId = addedMessage.parentId else { // Message is a post
            if posts.contains(addedMessage) {
                return
            }
            posts.append(message)
            postIdToReplies[addedMessage.id] = []
            return
        }
        // This means that parent ID exists and this is a reply to a post!
        if (postIdToReplies[parentId]?.contains(addedMessage)) != nil {
            return
        }
        postIdToReplies[parentId]?.append(addedMessage)
    }

    override func insertAll(messages: [Message]) {
        super.insertAll(messages: messages)

        // Insert root level posts first
        for rootLevelMessage in self.messages.filter({ $0.parentId == nil && $0.type != .keyExchange }) {
            posts.append(rootLevelMessage)
            self.postIdToReplies[rootLevelMessage.id] = []
        }

        // Now we insert the rest of the repplies
        for message in self.messages {
            guard let parentId = message.parentId else {
                // This message is not a reply
                continue
            }
            self.postIdToReplies[parentId]?.append(message)
        }
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
