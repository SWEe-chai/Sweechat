class GroupChatRoomViewModel: ChatRoomViewModel {
    var groupChatRoom: GroupChatRoom
    init(groupChatRoom: GroupChatRoom) {
        self.groupChatRoom = groupChatRoom
        super.init(chatRoom: groupChatRoom, user: groupChatRoom.currentUser)
    }
}
