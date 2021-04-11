class ThreadChatRoom: ChatRoom {
    // This init is to create the function
    init(postId: String, sender: User, forumMembers: [User]) {
        super.init(name: "Thread",
                   members: forumMembers,
                   currentUser: sender,
                   currentUserPermission: ChatRoomPermission.readWrite,
                   givenChatRoomId: postId)
    }

    // This init is when the thread is already created
    init(id: String, ownerId: String, currentUser: User) {
        super.init(id: id,
                   name: "Thread",
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.readWrite)
    }
}
