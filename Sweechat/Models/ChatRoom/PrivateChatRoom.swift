import Combine

class PrivateChatRoom: ChatRoom {
    var otherUser: User?
    var subscribers: [AnyCancellable] = []

    // Used by facade
    init(id: Identifier<ChatRoom>,
         ownerId: Identifier<User>,
         currentUser: User) {
        super.init(id: id,
                   name: "",
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.readWrite)
    }

    init(currentUser: User,
         otherUser: User) {
        let members = [currentUser, otherUser]
        super.init(name: "",
                   members: members,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.readWrite)
    }

    private func setOtherUser(_ user: User) {
        self.otherUser = user
        self.name = user.name
        self.profilePictureUrl = user.profilePictureUrl
    }

    private func setOtherUserConnection() {
        otherUser?.setUserConnection()
        if let nameSubscriber = otherUser?
            .subscribeToName(function: { newName in
            self.name = newName
        }) {
            subscribers.append(nameSubscriber)
        }
    }

    override func insert(member: User) {
        if member != currentUser {
            setOtherUser(member)
            setOtherUserConnection()
        }
        memberIdsToUsers[member.id] = member
        assert(members.count <= 2)
    }

    override func insertAll(members: [User]) {
        for member in members {
            insert(member: member)
        }
    }

    override func update(chatRoom: ChatRoom) {
        // Private chat does not update name and picture according to backend
    }
}
