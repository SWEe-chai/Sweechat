import Foundation
import os

class ChatRoomMediaCache {
    private var cacheSizeLimit = 200 * 1_024
    private var chatRoomId: String
    private var urlToData: [String: Data] = [:]

    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        self.fillImageCache()
    }

    // MARK: Handle images
    private func fillImageCache() {
        do {
            let itemDatas = try Persistence.shared().context
                .fetch(StoredImageData.fetchItemsInChatRoom(chatRoomId: chatRoomId, limitSize: cacheSizeLimit))
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

    private func loadImage(fromUrl url: String) -> Data? {
        do {
            let itemData = try Persistence.shared().context
                .fetch(StoredImageData.fetchItemInChatRoom(url: url, chatRoomId: chatRoomId))
            return itemData.first?.data
        } catch let error as NSError {
            os_log("Fetch error \(error)")
            return nil
        }
    }

    func getData(url: String, onCompletion: @escaping (Data?) -> Void) {
        // If it's in immediate cache
        if let data = urlToData[url] {
            onCompletion(data)
            return
        }

        // Check if in storage
        if let data = loadImage(fromUrl: url) {
            onCompletion(data)
            return
        }
        // Data is not in cache, must fetch
        guard let parsedURL = URL(string: url) else {
            onCompletion(nil)
            return
        }

        URLSession.shared.dataTask(with: parsedURL) { data, _, _ in
            onCompletion(data)
            guard let data = data, !data.isEmpty else {
                return
            }
            self.delete(imageWithUrl: url)
            self.save(imageWithUrl: url, data: data)
        }.resume()
    }

    private func delete(imageWithUrl url: String) {
        let deleteRequest = StoredImageData.delete(url: url, from: chatRoomId)
        do {
            try Persistence.shared().context.execute(deleteRequest)
        } catch {
            os_log("Failed to execute delete request: \(error.localizedDescription)")
        }
    }

    private func save(imageWithUrl url: String, data: Data) {
        let storageItem = StoredImageData(context: Persistence.shared().context)
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

    // MARK: Handle videos

    private func delete(videoWithLocalUrl url: String) {
        let deleteRequest = StoredVideoData.delete(url: url, from: chatRoomId)
        do {
            try Persistence.shared().context.execute(deleteRequest)
        } catch {
            os_log("Failed to execute delete request: \(error.localizedDescription)")
        }
    }

    private func save(videoWithLocalUrl url: String) {
        let storageItem = StoredVideoData(context: Persistence.shared().context)
        storageItem.chatRoomId = chatRoomId
        storageItem.localUrl = url
        do {
            try Persistence.shared().context.save()
        } catch {
            os_log("Failed to save: \(error.localizedDescription)")
        }
    }

    func getLocalUrl(fromOnlineUrl onlineUrl: String, onCompletion: @escaping (String?) -> Void) {
        guard let destinationUrl = getDestinationUrlFrom(onlineUrl: onlineUrl) else {
            // Cannot fetch from the URL, URL probably invalid
            onCompletion(nil)
            return
        }

        if FileManager().fileExists(atPath: destinationUrl.path) {
            onCompletion(destinationUrl.path)
            return
        }

        guard let url = URL(string: onlineUrl) else {
            onCompletion(nil)
            os_log("Video exists")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                os_log("Video Fetch Error: \(error.localizedDescription)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                os_log("Video fetch: Non 200 response")
                return
            }

            DispatchQueue.main.async {
                if let data = data,
                   !FileManager().fileExists(atPath: destinationUrl.path) {
                    try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                }
            }
            onCompletion(destinationUrl.path)
            self.delete(videoWithLocalUrl: destinationUrl.path)
            self.save(videoWithLocalUrl: destinationUrl.path)
        }).resume()

    }

    private func getDestinationUrlFrom(onlineUrl: String) -> URL? {
        guard let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let hash = onlineUrl.split(separator: "/").last,
              let url = hash.split(separator: ".").first else {
            return nil
        }
        return docsUrl.appendingPathComponent("\(url).MOV")
    }
}

extension ChatRoomMediaCache {
    // Put this separately for dev util
    private func deleteAll() {
        let deleteRequest = StoredImageData.deleteAll()
        do {
            try Persistence.shared().context
                .execute(deleteRequest)
        } catch {
            os_log("Failed to delete all: \(error.localizedDescription)")
        }
    }
}
