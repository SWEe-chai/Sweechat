import FirebaseFirestore
import os

/**
 An adapater for translating `Message` between model and Firebase representations.
 */
struct FirebaseMessageAdapter {
    /// Converts the specified Firebase document into a model `Message`.
    /// - Parameters:
    ///   - document: The specified Firebase document.
    /// - Returns: A model `Message`, or nil if the conversion fails.
    static func convert(document: DocumentSnapshot) -> Message? {
        if !document.exists {
            os_log("Error: Cannot convert message, message document does not exist")
            return nil
        }
        let data = document.data()

        guard let creationTime = data?[DatabaseConstant.Message.creationTime] as? Timestamp,
              let senderIdStr = data?[DatabaseConstant.Message.senderId] as? String,
              let receiverIdStr = data?[DatabaseConstant.Message.receiverId] as? String,
              let messageTypeStr = data?[DatabaseConstant.Message.type] as? String,
              let parentIdStr = data?[DatabaseConstant.Message.parentId] as? String?,
              let likers = data?[DatabaseConstant.Message.likers] as? [String] else {
            os_log("Error converting data for Message, data: %s", String(describing: data))
            return nil
        }

        guard let messageType = MessageType(rawValue: messageTypeStr) else {
            os_log("Unable to initialise MessageType enum, obtained messageTypeStr: \(messageTypeStr)")
            return nil
        }

        let id: Identifier<Message> = Identifier(val: document.documentID)
        let parentId: Identifier<Message>? = IdentifierConverter.toOptionalMessageId(from: parentIdStr)
        let senderId = Identifier<User>(val: senderIdStr)
        let receiverId = Identifier<User>(val: receiverIdStr)
        if let content = data?[DatabaseConstant.Message.content] as? Data {
            return Message(
                id: id,
                senderId: senderId,
                creationTime: creationTime.dateValue(),
                content: content,
                type: messageType,
                receiverId: receiverId,
                parentId: parentId,
                likers: Set(likers.map({ Identifier<User>(val: $0) }))
            )
        }
        return nil
    }

    /// Converts the specified `Message` into a Firebase compatible dictionary.
    /// - Parameters:
    ///   - message: The specified `Message`.
    /// - Returns: A Firebase compatible dictionary based on the specified `Message`.
    static func convert(message: Message) -> [String: Any] {
        var map: [String: Any] =
        [
            DatabaseConstant.Message.creationTime: message.creationTime,
            DatabaseConstant.Message.senderId: message.senderId.val,
            DatabaseConstant.Message.content: message.content,
            DatabaseConstant.Message.type: message.type.rawValue,
            DatabaseConstant.Message.receiverId: message.receiverId.val,
            DatabaseConstant.Message.likers: Array(message.likers).map({ $0.val })
        ]

        // This means that in Firestore, some Message document might have
        // a parentId, some might not. Non-existence of parentId is used
        // to translate it to `nil`
        if let parentId = message.parentId?.val {
            map[DatabaseConstant.Message.parentId] = parentId
        }

        return map
    }

}
