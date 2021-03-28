import Foundation

enum ChatRoomType {
    case normal
    case readOnly

    static func convert(permission: ChatRoomPermissionBitmask) -> ChatRoomType {
        if permission >> 1 % 2 == 1 {
            return .normal
        }
        return .readOnly
    }
}
