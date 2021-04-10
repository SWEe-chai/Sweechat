protocol ThreadCreator: AnyObject {
    func createThreadChatRoom(id: String, currentUser: User, forumMembers: [User], onCompletion: (() -> Void)?)
}
