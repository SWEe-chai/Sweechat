protocol ThreadCreator: AnyObject {
    func createThreadChatRoom(id: Identifier<ChatRoom>, currentUser: User, forumMembers: [User], onCompletion: (() -> Void)?)
}
