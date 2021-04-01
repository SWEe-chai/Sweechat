import Combine

class PrivateChatRoom: ChatRoom {
    var otherUser: User?
    var subscribers: [AnyCancellable] = []

    // Used by facade
    init(id: String,
         currentUser: User) {
        super.init(id: id,
                   name: "",
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
}
