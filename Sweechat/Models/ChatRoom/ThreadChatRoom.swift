class ThreadChatRoom: ChatRoom {
    // This init is to create the function
    init(postId: Identifier<ChatRoom>, sender: User, forumMembers: [User]) {
        super.init(name: "Thread",
                   members: forumMembers,
                   currentUser: sender,
                   currentUserPermission: ChatRoomPermission.readWrite,
                   isStarred: false,
                   givenChatRoomId: postId)
    }

    // This init is when the thread is already created
    init(id: Identifier<ChatRoom>, ownerId: Identifier<User>, currentUser: User) {
        super.init(id: id,
                   name: "Thread",
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.readWrite,
                   isStarred: false)
    }
}
