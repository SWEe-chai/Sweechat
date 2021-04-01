import Foundation

enum ChatRoomViewModelType: String {
    case normal
    case readOnly

    static func convert(
        permission: ChatRoomPermissionBitmask) -> ChatRoomViewModelType {
        if permission & ChatRoomPermission.write != 0 {
            return .normal
        }
        return .readOnly
    }
}
