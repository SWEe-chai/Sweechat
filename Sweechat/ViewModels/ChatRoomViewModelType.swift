import Foundation

enum ChatRoomViewModelType: String {
    case normal
    case readOnly

    static func convert(permission: ChatRoomPermissionBitmask) -> ChatRoomViewModelType {
        if permission >> 1 % 2 == 1 {
            return .normal
        }
        return .readOnly
    }
}
