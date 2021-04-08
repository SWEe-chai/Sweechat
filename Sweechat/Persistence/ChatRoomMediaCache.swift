import Foundation

class ChatRoomMediaCache {
    private var persistence: Persistence
    private var chatRoomId: String
    private var urlToData: [String: Data] = [:]

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        self.persistence = Persistence(.inDisk)
        loadAllChatRoomData()
    }

    private func loadAllChatRoomData() {
        // TODO: Fetch url - data pairs
    }

    func getData(url: String) -> Data? {
        urlToData[url]
    }
}
