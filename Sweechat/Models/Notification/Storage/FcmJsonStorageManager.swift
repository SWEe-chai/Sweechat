import Foundation
import os

struct FcmJsonStorageManager: FcmStorageManager {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    static let tokenFileNameFormat = "token"
    static let fileExtension = ".json"

    static func save(token: String?) {
        if let token = token {
            let url = StorageManager.getFileURL(from: String(format: tokenFileNameFormat), with: fileExtension)
            guard let tokenData = try? jsonEncoder.encode(token) else {
                return
            }

            do {
                try tokenData.write(to: url)
            } catch {
                os_log("Write token error")
            }
        }
    }

    static func load() -> String? {
        let url = StorageManager.getFileURL(from: String(format: tokenFileNameFormat), with: fileExtension)

        guard let tokenData = try? Data(contentsOf: url) else {
            // Cannot find save file
            return nil
        }

        guard let token = try? jsonDecoder.decode(String.self, from: tokenData) else {
            return nil
        }
        return token
    }
}
