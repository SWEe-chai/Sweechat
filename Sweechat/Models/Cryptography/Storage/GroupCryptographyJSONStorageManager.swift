import Foundation

struct GroupCryptographyJSONStorageManager: GroupCryptographyStorageManager {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let fileNameFormat = "%@_serverKeyBundles"
    private let fileExtension = ".json"

    func save(userId: String, privateServerKeyBundle: [String: Data], publicServerKeyBundle: [String: Data]) throws {
        let bundleArray = [privateServerKeyBundle, publicServerKeyBundle]
        let url = getFileURL(from: String(format: fileNameFormat, userId), with: fileExtension)

        guard let bundleArrayData = try? jsonEncoder.encode(bundleArray) else {
            throw SignalProtocolError(message: "Unable to encode key bundle for saving")
        }

        do {
            try bundleArrayData.write(to: url)
        } catch {
            throw SignalProtocolError(message: "Unable to save key bundle")
        }
    }

    func loadServerKeyBundles(userId: String) throws -> ([String: Data], [String: Data])? {
        let url = getFileURL(from: String(format: fileNameFormat, userId), with: fileExtension)

        // Cannot find save file
        guard let bundleArrayData = try? Data(contentsOf: url) else {
            return nil
        }

        guard let bundleArray = try? jsonDecoder.decode([[String: Data]].self, from: bundleArrayData) else {
            throw SignalProtocolError(message: "Unable to decode key bundle during loading")
        }

        return (bundleArray[0], bundleArray[1])
    }

    private func getFileURL(from name: String, with fileExtension: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(name).appendingPathExtension(fileExtension)
    }
}
