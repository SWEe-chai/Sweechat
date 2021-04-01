import Combine

class PrivateChatRoom: ChatRoom {
    var otherUser: User?
    var subscribers: [AnyCancellable] = []

    init(id: String,
         name: String,
         currentUser: User,
         otherUser: User? = nil,
         profilePictureUrl: String? = nil) {
        let members: [User] = [currentUser, otherUser].compactMap { $0 }

        super.init(id: id,
                   name: "",
                   currentUser: currentUser,
                   permissions: ChatRoomPermission.readWrite,
                   members: members,
                   profilePictureUrl: profilePictureUrl)
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
