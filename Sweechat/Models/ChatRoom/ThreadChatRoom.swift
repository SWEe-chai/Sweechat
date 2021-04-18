import Foundation

/**
 Represents a thread chat room in the application.
 */
class ThreadChatRoom: ChatRoom {
    var mostPopularMessage: Message? {
        messages.values.max { a, b in a.likers.count < b.likers.count }
    }

    /// Constructs a `ThreadChatRoom` for use in facade translation with the cloud service provider.
    init(postId: Identifier<ChatRoom>, sender: User, forumMembers: [User]) {
        super.init(name: "Thread",
                   members: forumMembers,
                   currentUser: sender,
                   currentUserPermission: ChatRoomPermission.readWrite,
                   isStarred: false,
                   givenChatRoomId: postId)
    }

    /// Constructs a `ThreadChatRoom` to display on the screen.
    init(id: Identifier<ChatRoom>, ownerId: Identifier<User>, currentUser: User) {
        super.init(id: id,
                   name: "Thread",
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.readWrite,
                   isStarred: false,
                   creationTime: Date())
    }
}
