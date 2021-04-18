import Foundation
import os

/**
 A representation os a JSON-based storage manager for storing Firebase cloud messaging tokens.
 */
struct FcmJsonStorageManager: FcmStorageManager {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    static let tokenFileNameFormat = "token"
    static let fileExtension = ".json"

    /// Saves the specified Firebase token
    /// - Parameters:
    ///   - token: The specified Firebase token, or nil if unavailable.
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

    /// Loads and returns the Firebase cloud messaging token for this device.
    /// - Returns: The Firebase cloud messaging token for this device.
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
