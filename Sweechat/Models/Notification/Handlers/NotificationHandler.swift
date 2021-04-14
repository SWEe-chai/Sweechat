//
//  NotificationHandler.swift
//  Sweechat
//
//  Created by Agnes Natasya on 13/4/21.

 import UserNotifications
 import Firebase

// [START ios_10_message_handling]
@available(iOS 10, *)
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    var appViewModel: AppViewModel
    var notificationMetadata: NotificationMetadata

    init(appViewModel: AppViewModel, notificationMetadata: NotificationMetadata) {
        self.appViewModel = appViewModel
        self.notificationMetadata = notificationMetadata
    }

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[NotificationConstant.gcmMessageIDKey] {
          print("Message ID 1: \(messageID)")
        }
        // [END_EXCLUDE]

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[NotificationConstant.gcmMessageIDKey] {
          print("Message ID 5: \(messageID)")
        }
        // [END_EXCLUDE]
        notificationMetadata.isFromNotif = true
        print("KESINI DONG GUYSSSS \(notificationMetadata.isFromNotif)")
        notificationMetadata.directModuleId = userInfo["gcm.notification.moduleId"] as? String ?? ""
        notificationMetadata.directChatRoomId = userInfo["gcm.notification.chatRoomId"] as? String ?? ""

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)

        completionHandler()
    }
}
// [END ios_10_message_handling]

extension NotificationHandler: MessagingDelegate {
    // [START refresh_token]
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String
    ) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        FcmJsonStorageManager.save(token: fcmToken)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}
