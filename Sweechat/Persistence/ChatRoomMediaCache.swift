import Foundation
import os

class ChatRoomMediaCache {
    private var cacheSizeLimitInBytes = 200 * 1_024
    private var chatRoomId: Identifier<ChatRoom>
    private var urlStringToImageData: [String: Data] = [:]

    init(chatRoomId: Identifier<ChatRoom>) {
        self.chatRoomId = chatRoomId
        self.fillImageCache()
    }

    // MARK: Handle images
    private func fillImageCache() {
        do {
            let itemDatas = try Persistence.shared().context
                .fetch(
                    StoredImageData.fetchItemsInChatRoom(chatRoomId: chatRoomId.val, limitSize: cacheSizeLimitInBytes)
                )
            for itemData in itemDatas {
                guard let urlString = itemData.urlString,
                      let data = itemData.data else {
                    os_log("Unable to translate StoredImageData, data: \(itemData)")
                    return
                }
                urlStringToImageData[urlString] = data
            }
        } catch let error as NSError {
            os_log("Fetch error \(error)")
        }
    }

    private func loadImage(fromURlString urlString: String) -> Data? {
        do {
            let itemData = try Persistence.shared().context
                .fetch(StoredImageData.fetchItemInChatRoom(urlString: urlString, chatRoomId: chatRoomId.val))
            guard let data = itemData.first?.data else {
                os_log("Data with url \(urlString) does not exist")
                return nil
            }
            return data
        } catch let error as NSError {
            os_log("Fetch error \(error)")
            return nil
        }
    }

    func getData(urlString: String, onCompletion: @escaping (Data?) -> Void) {
        // If it's in immediate cache
        if let data = urlStringToImageData[urlString] {
            onCompletion(data)
            return
        }

        // Check if in storage
        if let data = loadImage(fromURlString: urlString) {
            onCompletion(data)
            return
        }
        // Data is not in cache, must fetch
        guard let parsedURL = URL(string: urlString) else {
            onCompletion(nil)
            return
        }

        URLSession.shared.dataTask(with: parsedURL) { data, _, _ in
            onCompletion(data)
            guard let data = data, !data.isEmpty else {
                return
            }
            self.delete(imageWithUrlString: urlString)
            self.save(imageWithUrlString: urlString, data: data)
        }.resume()
    }

    private func delete(imageWithUrlString urlString: String) {
        // NSManagedObject, need String
        let deleteRequest = StoredImageData.delete(urlString: urlString, from: chatRoomId.val)
        do {
            try Persistence.shared().context.execute(deleteRequest)
        } catch {
            os_log("Failed to execute delete request: \(error.localizedDescription)")
        }
    }

    private func save(imageWithUrlString urlString: String, data: Data) {
        let storageItem = StoredImageData(context: Persistence.shared().context)
        storageItem.chatRoomId = chatRoomId.val // NSManagedObject, need String
        storageItem.data = data
        storageItem.size = Int64(MemoryLayout.size(ofValue: data))
        storageItem.urlString = urlString
        do {
            try Persistence.shared().context.save()
        } catch {
            os_log("Failed to save: \(error.localizedDescription)")
        }
    }

    // MARK: Handle videos

    private func delete(videoWithLocalUrlString urlString: String) {
        let deleteRequest = StoredVideoData.delete(urlString: urlString, from: chatRoomId.val)
        do {
            try Persistence.shared().context.execute(deleteRequest)
        } catch {
            os_log("Failed to execute delete request: \(error.localizedDescription)")
        }
    }

    private func save(videoWithLocalUrlString urlString: String) {
        let storageItem = StoredVideoData(context: Persistence.shared().context)
        storageItem.chatRoomId = chatRoomId.val
        storageItem.localUrlString = urlString
        do {
            try Persistence.shared().context.save()
        } catch {
            os_log("Failed to save: \(error.localizedDescription)")
        }
    }

    func getLocalUrl(fromOnlineUrlString onlineUrlString: String, onCompletion: @escaping (URL?) -> Void) {
        guard let destinationUrl = getDestinationUrlFrom(onlineUrlString: onlineUrlString) else {
            // Cannot fetch from the URL, URL probably invalid
            onCompletion(nil)
            return
        }

        if FileManager().fileExists(atPath: destinationUrl.path) {
            onCompletion(destinationUrl)
            return
        }

        guard let url = URL(string: onlineUrlString) else {
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
            onCompletion(destinationUrl)
            self.delete(videoWithLocalUrlString: destinationUrl.path)
            self.save(videoWithLocalUrlString: destinationUrl.path)
        }).resume()

    }

    private func getDestinationUrlFrom(onlineUrlString: String) -> URL? {
        /*
            https://<<domain>>/<<routes>>/0D2F9E68-4D18-47D9-9782-00C841B4F3CE.MOV?<<query param>>
         */
        guard let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let hash = onlineUrlString.split(separator: "/").last,
              hash.split(separator: ".").count >= 2,
              let url = hash.split(separator: ".").first,
              let ext = hash.split(separator: ".")[1].split(separator: "?").first else {
            os_log("Unexpected online url, please check with developers. url: \(onlineUrlString)")
            return nil
        }
        return docsUrl.appendingPathComponent("\(url).\(ext)")
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

// MARK: MediaMessageViewModelDelegate
extension ChatRoomMediaCache: MediaMessageViewModelDelegate {
    func fetchLocalUrl(fromUrlString urlString: String, onCompletion: @escaping (URL?) -> Void) {
        getLocalUrl(fromOnlineUrlString: urlString, onCompletion: onCompletion)
    }

    func fetchImageData(fromUrlString urlString: String, onCompletion: @escaping (Data?) -> Void) {
        getData(urlString: urlString, onCompletion: onCompletion)
    }
}
