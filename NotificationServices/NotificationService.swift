//
//  NotificationService.swift
//  NotificationServices
//
//  Created by Agnes Natasya on 12/4/21.
//

import UserNotifications
import os
// @testable import Sweechat

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
//            let receiverId = bestAttemptContent.userInfo["gcm.notification.receiverId"]
//            let chatRoomId = bestAttemptContent.userInfo["gcm.notification.chatRoomId"]
//            let groupCryptographyProvider = SignalProtocol(userId: receiverId as! String)
//            let decryptMessage = decryptMessageContent(
//            groupCryptographyProvider: groupCryptographyProvider, chatRoom
//            messageContent: bestAttemptContent.body as! Data
//            )
            bestAttemptContent.title = "\(bestAttemptContent.title)"
//            bestAttemptContent.body = decryptMessage as! String

            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

//    private func decryptMessageContent(groupCryptographyProvider: SignalProtocol, chatRoomId: String, messageContent: Data) -> Data {
//        if let content = try? groupCryptographyProvider.decrypt(ciphertextData: messageContent, groupId: chatRoomId) {
//            return content
//        }
//
//        os_log("Unable to decrypt chat room message")
//        return ChatRoom.failedEncryptionMessageContent.toData()
//    }
}
