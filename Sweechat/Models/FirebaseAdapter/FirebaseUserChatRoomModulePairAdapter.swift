import FirebaseFirestore
import os

/**
 An adapter for translating between `FirebaseUserChatRoomModulePair` and its Firebase representation.
 */
struct FirebaseUserChatRoomModulePairAdapter {
    /// Converts the specified Firebase document into a `FirebaseUserChatRoomModulePair`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    /// - Returns: A `FirebaseUserChatRoomModulePair` based on the specified Firebase document,
    ///            or nil if the conversion fails.
    static func convert(document: DocumentSnapshot) -> FirebaseUserChatRoomModulePair? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let userIdStr = data?[DatabaseConstant.UserChatRoomModulePair.userId] as? String,
              let chatRoomIdStr = data?[DatabaseConstant.UserChatRoomModulePair.chatRoomId] as? String,
              let moduleIdStr = data?[DatabaseConstant.UserChatRoomModulePair.moduleId] as? String,
              let permissions = data?[DatabaseConstant.UserChatRoomModulePair.permissions]
                as? ChatRoomPermissionBitmask else {
            os_log("Error converting data for UserChatRoomModulePair, data: %s", String(describing: data))
            return nil
        }

        let userId = Identifier<User>(val: userIdStr)
        let chatRoomId = Identifier<ChatRoom>(val: chatRoomIdStr)
        let moduleId = Identifier<Module>(val: moduleIdStr)
        return FirebaseUserChatRoomModulePair(
            userId: userId,
            chatRoomId: chatRoomId,
            moduleId: moduleId,
            permissions: permissions)
    }

    /// Converts the specified `FirebaseUserChatRoomModulePair` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - pair: The specified `FirebaseUserChatRoomModulePair`.
    /// - Returns: A Firebase compatible dictionary based on the specified `FirebaseUserChatRoomModulePair`.
    static func convert(pair: FirebaseUserChatRoomModulePair) -> [String: Any] {
        [
            DatabaseConstant.UserChatRoomModulePair.userId: pair.userId.val,
            DatabaseConstant.UserChatRoomModulePair.chatRoomId: pair.chatRoomId.val,
            DatabaseConstant.UserChatRoomModulePair.moduleId: pair.moduleId.val,
            DatabaseConstant.UserChatRoomModulePair.permissions: pair.permissions
        ]
    }
}
