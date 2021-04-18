import Combine
import Foundation

/**
 Represents a forum chat room in the application.
 */
class ForumChatRoom: ChatRoom {
    /// Constructs a `ForumChatRoom` for use in facade translation with the cloud service provider.
    override init(id: Identifier<ChatRoom>,
                  name: String,
                  ownerId: Identifier<User>,
                  currentUser: User,
                  currentUserPermission: ChatRoomPermissionBitmask,
                  isStarred: Bool,
                  creationTime: Date,
                  profilePictureUrl: String? = nil) {
        assert(ChatRoomPermission.canRead(permission: currentUserPermission)
                && ChatRoomPermission.canWrite(permission: currentUserPermission),
               "Assertion failed, forum user cannot read write")
        super.init(id: id,
                   name: name,
                   ownerId: ownerId,
                   currentUser: currentUser,
                   currentUserPermission: currentUserPermission,
                   isStarred: isStarred,
                   creationTime: creationTime,
                   profilePictureUrl: profilePictureUrl)
    }

    /// Constructs a `ForumChatRoom` to display on the screen.
    init(name: String,
         members: [User],
         currentUser: User,
         isStarred: Bool,
         profilePictureUrl: String? = nil) {
        super.init(name: name,
                   members: members,
                   currentUser: currentUser,
                   currentUserPermission: ChatRoomPermission.all, // Creator gets all permissions
                   isStarred: isStarred,
                   profilePictureUrl: profilePictureUrl)
    }
}
