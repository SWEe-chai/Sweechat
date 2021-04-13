enum ChatRoomListType: String {
    case groupChat = "Groups"
    case privateChat = "Private"
    case forum = "Forums"
    case starred = "Starred"

    static func allTypes() -> [ChatRoomListType] {
        [.groupChat, .privateChat, .forum, .starred]
    }
}
