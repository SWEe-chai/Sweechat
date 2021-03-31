import Combine

class PrivateChatRoom: ChatRoom {
    var otherUser: User?
    var subscribers: [AnyCancellable] = []

    override init(id: String,
                  name: String,
                  currentUser: User,
                  profilePictureUrl: String? = nil) {
        super.init(id: id,
                   name: "",
                   currentUser: currentUser,
                   profilePictureUrl: profilePictureUrl)
    }

    override init(name: String,
                  members: [User],
                  currentUser: User,
                  profilePictureUrl: String? = nil) {
        super.init(name: "",
                   members: members,
                   currentUser: currentUser,
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
