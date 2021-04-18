import Foundation

typealias ChatRoomPermissionBitmask = UInt32

/**
 Represents chat room permissions in the application.
 */
struct ChatRoomPermission {
    static let none: ChatRoomPermissionBitmask = 0
    static let read: ChatRoomPermissionBitmask = 0b1
    static let write: ChatRoomPermissionBitmask = 0b1 << 1
    static let invite: ChatRoomPermissionBitmask = 0b1 << 2
    static let pin: ChatRoomPermissionBitmask = 0b1 << 3

    static let readWrite: ChatRoomPermissionBitmask =
        ChatRoomPermission.read | ChatRoomPermission.write
    static let all: ChatRoomPermissionBitmask =
        ChatRoomPermission.readWrite |
        ChatRoomPermission.invite | ChatRoomPermission.pin

    /// Returns true if the specified `ChatRoomPermissionBitmask` allows reading.
    /// - Parameters:
    ///  - permission: The specified `ChatRoomPermissionBitmask`.
    static func canRead(permission: ChatRoomPermissionBitmask) -> Bool {
        permission & read != 0
    }

    /// Returns true if the specified `ChatRoomPermissionBitmask` allows writing.
    /// - Parameters:
    ///  - permission: The specified `ChatRoomPermissionBitmask`.
    static func canWrite(permission: ChatRoomPermissionBitmask) -> Bool {
        permission & write != 0
    }
}
