import Combine

/**
 Repesents metadata for push notifications.
 */
class NotificationMetadata {
    var directChatRoomId: String
    var directModuleId: String

    @Published var isFromNotif: Bool

    private var defaultIsFromNotifValue = false
    private var defaultDirectModuleIdValue = ""
    private var defaultDirectChatRoomIdValue = ""

    /// Constructs an instance of `NotificationMetaData` with the specified information.
    init(isFromNotif: Bool, directModuleId: String, directChatRoomId: String) {
        self.isFromNotif = isFromNotif
        self.directModuleId = directModuleId
        self.directChatRoomId = directChatRoomId
    }

    /// Constructs an instance of `NotificationMetaData`.
    init() {
        self.isFromNotif = defaultIsFromNotifValue
        self.directModuleId = defaultDirectModuleIdValue
        self.directChatRoomId = defaultDirectChatRoomIdValue
    }

    /// Subscribes to the this `NotificationMetaData`'s `isFromNotif` flag
    /// by executing the specified function on change to the flag.
    /// - Parameters:
    ///   - function: The specified function to execute on change to the profile picture.
    /// - Returns: An `AnyCancellable` that executes the specified closure when cancelled.
    func subscribeToIsFromNotif(function: @escaping (Bool) -> Void) -> AnyCancellable {
        $isFromNotif.sink(receiveValue: function)
    }

    /// Resets this `NotificationMetaData` to the default values.
    func reset() {
        self.isFromNotif = defaultIsFromNotifValue
        self.directModuleId = defaultDirectModuleIdValue
        self.directChatRoomId = defaultDirectChatRoomIdValue
    }
}
