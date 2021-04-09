import Foundation
import os

class ChatRoomMediaCache {
    private var oneMb = 1_024 * 1_024
    private var chatRoomId: String
    private var urlToData: [String: Data] = [:]

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
//        loadAllChatRoomData()
    }

    private func loadAllChatRoomData() {
        do {
            let itemDatas = try Persistence.shared().context
                .fetch(StoredItemData.fetchItemsInChatRoom(chatRoomId: chatRoomId, limitSize: oneMb))
            for itemData in itemDatas {
                guard let url = itemData.url,
                      let data = itemData.data else {
                    return
                }
                urlToData[url] = data
            }
        } catch let error as NSError {
            os_log("Fetch error \(error)")
        }
    }

    private func loadData(url: String) -> Data? {
        do {
            let itemData = try Persistence.shared().context
                .fetch(StoredItemData.fetchItemInChatRoom(url: url, chatRoomId: chatRoomId))
            return itemData.first?.data
        } catch let error as NSError {
            os_log("Fetch error \(error)")
            return nil
        }
    }

    func getData(url: String, onCompletion: @escaping (Data?) -> Void) {
        // If it's in immediate cache
        if let data = urlToData[url] {
            print("in cache")
            onCompletion(data)
            return
        }

        // Check if in storage
        if let data = loadData(url: url) {
            print("in disk")
            onCompletion(data)
            return
        }

        // Data is not in cache, must fetch
        guard let parsedURL = URL(string: url) else {
            onCompletion(nil)
            return
        }

        URLSession.shared.dataTask(with: parsedURL) { data, _, _ in
            print("queried")
            onCompletion(data)
            guard let data = data, !data.isEmpty else {
                return
            }
            self.delete(url: url)
            self.save(url: url, data: data)
        }.resume()
    }

    private func delete(url: String) {
        let deleteRequest = StoredItemData.delete(url: url, from: chatRoomId)
        do {
            try Persistence.shared().context
                .execute(deleteRequest)
        } catch {
            os_log("Failed to execute delete request: \(error.localizedDescription)")
        }
    }

    private func save(url: String, data: Data) {
        let storageItem = StoredItemData(context: Persistence.shared().context)
        storageItem.chatRoomId = chatRoomId
        storageItem.data = data
        storageItem.size = Int64(MemoryLayout.size(ofValue: data))
        storageItem.url = url
        do {
            try Persistence.shared().context.save()
        } catch {
            os_log("Failed to save: \(error.localizedDescription)")
        }
    }
}

extension ChatRoomMediaCache {
    // Put this separately for dev util
    private func deleteAll() {
        let deleteRequest = StoredItemData.deleteAll()
        do {
            try Persistence.shared().context
                .execute(deleteRequest)
        } catch {
            os_log("Failed to delete all: \(error.localizedDescription)")
        }
    }
}
