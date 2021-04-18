import FirebaseFirestore
import os

/**
 An adapter for translating between `ChatRoom` and its Firebase representation.
 */
struct FirebaseChatRoomAdapter {
    /// Converts the specified Firebase document, `User`, and permissions into a `ChatRoom`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    ///   - user: The specified `User`.
    ///   - permissions: The specified permissions.
    /// - Returns: A `ChatRoom` based on the specified Firebase document, or nil if the conversion fails.
    static func convert(document: DocumentSnapshot,
                        user: User,
                        withPermissions permissions: ChatRoomPermissionBitmask) -> ChatRoom? {
        if !document.exists {
            os_log("Error: Cannot convert chat room, chat room document does not exist")
            return nil
        }
        let data = document.data()
        guard let idString = data?[DatabaseConstant.ChatRoom.id] as? String,
              let name = data?[DatabaseConstant.ChatRoom.name] as? String,
              let ownerIdStr = data?[DatabaseConstant.ChatRoom.ownerId] as? String,
              let profilePictureUrl = data?[DatabaseConstant.User.profilePictureUrl] as? String,
              let type = ChatRoomType(rawValue: data?[DatabaseConstant.ChatRoom.type] as? String ?? ""),
              let isStarred = data?[DatabaseConstant.ChatRoom.isStarred] as? Bool,
              let creationTime = data?[DatabaseConstant.ChatRoom.creationTime] as? Timestamp
              else {
            os_log("Error converting data for ChatRoom, data: %s", String(describing: data))
            return nil
        }

        let id = Identifier<ChatRoom>(val: idString)
        let ownerId = Identifier<User>(val: ownerIdStr)
        switch type {
        case .groupChat:
            return GroupChatRoom(
                id: id,
                name: name,
                ownerId: ownerId,
                currentUser: user,
                currentUserPermission: permissions,
                isStarred: isStarred,
                creationTime: creationTime.dateValue(),
                profilePictureUrl: profilePictureUrl)
        case .privateChat:
            return PrivateChatRoom(
                id: id,
                ownerId: ownerId,
                currentUser: user,
                creationTime: creationTime.dateValue())
        case .forum:
            return ForumChatRoom(
                id: id,
                name: name,
                ownerId: ownerId,
                currentUser: user,
                currentUserPermission: permissions,
                isStarred: isStarred,
                creationTime: creationTime.dateValue(),
                profilePictureUrl: profilePictureUrl)
        case .thread:
            return ThreadChatRoom(
                id: id,
                ownerId: ownerId,
                currentUser: user)
        }
    }

    /// Converts the specified `ChatRoom` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - message: The specified `ChatRoom`.
    /// - Returns: A Firebase compatible dictionary based on the specified `ChatRoom`.
    static func convert(chatRoom: ChatRoom) -> [String: Any] {
        var document: [String: Any] = [
            DatabaseConstant.ChatRoom.id: chatRoom.id.val,
            DatabaseConstant.ChatRoom.name: chatRoom.name,
            DatabaseConstant.ChatRoom.ownerId: chatRoom.ownerId.val,
            DatabaseConstant.ChatRoom.isStarred: chatRoom.isStarred,
            DatabaseConstant.ChatRoom.profilePictureUrl: chatRoom.profilePictureUrl ?? "",
            DatabaseConstant.ChatRoom.creationTime: chatRoom.creationTime
        ]
        switch chatRoom {
        case chatRoom as PrivateChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.privateChat.rawValue
        case chatRoom as GroupChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.groupChat.rawValue
        case chatRoom as ForumChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.forum.rawValue
        case chatRoom as ThreadChatRoom:
            document[DatabaseConstant.ChatRoom.type] = ChatRoomType.thread.rawValue
        default:
            os_log("Firebase ChatRoom Facade: Trying to convert abstract class ChatRoom")
            fatalError("ChatRoom must be either a group chat or private chat")
        }
        return document
    }
}
