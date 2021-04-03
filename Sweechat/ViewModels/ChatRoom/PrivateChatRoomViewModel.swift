class PrivateChatRoomViewModel: ChatRoomViewModel {
    var privateChatRoom: PrivateChatRoom
    init(privateChatRoom: PrivateChatRoom) {
        self.privateChatRoom = privateChatRoom
        super.init(chatRoom: privateChatRoom, user: privateChatRoom.currentUser)
    }
}
