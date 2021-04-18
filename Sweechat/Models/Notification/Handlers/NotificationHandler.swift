import UserNotifications
import Firebase

 /**
  Represents a notificaiton handler for handling push notifications.
  */
@available(iOS 10, *)
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    var notificationMetadata: NotificationMetadata

    /// Constructs a `NotificationHandler` from the specified `NotificationMetaData`.
    /// - Parameters:
    ///   - notificationMetadata: The specified `NotificationMetadata`.
    init(notificationMetadata: NotificationMetadata) {
        self.notificationMetadata = notificationMetadata
    }

    /// A helper method for handling push-notification taps.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        notificationMetadata.isFromNotif = true
        notificationMetadata.directModuleId = userInfo[NotificationConstant.gcmModuleId] as? String ?? ""
        notificationMetadata.directChatRoomId = userInfo[NotificationConstant.gcmChatRoomId] as? String ?? ""

        completionHandler()
    }
}

extension NotificationHandler: MessagingDelegate {
    /// A helper method for handling Firebase registration tokens for push notifications.
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String
    ) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = [DatabaseConstant.User.token: fcmToken]
        NotificationCenter.default.post(name: Notification.Name(NotificationConstant.fcmToken),
                                        object: nil,
                                        userInfo: dataDict)
        FcmJsonStorageManager.save(token: fcmToken)
    }
}
