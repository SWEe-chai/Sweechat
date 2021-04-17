import Foundation

struct GroupCryptographyJsonStorageManager: GroupCryptographyStorageManager {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let serverKeyBundlesFileNameFormat = "%@_serverKeyBundles"
    private let chainKeyFileNameFormat = "%@_%@_chainKeys"
    private let fileExtension = ".json"

    func save(userId: String, privateServerKeyBundle: [String: Data], publicServerKeyBundle: [String: Data]) throws {
        let bundleArray = [privateServerKeyBundle, publicServerKeyBundle]
        let url = StorageManager.getFileURL(from: String(format: serverKeyBundlesFileNameFormat, userId),
                                            with: fileExtension)

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
        let url = StorageManager.getFileURL(from: String(format: serverKeyBundlesFileNameFormat, userId),
                                            with: fileExtension)

        guard let bundleArrayData = try? Data(contentsOf: url) else {
            // Cannot find save file
            return nil
        }

        guard let bundleArray = try? jsonDecoder.decode([[String: Data]].self, from: bundleArrayData) else {
            throw SignalProtocolError(message: "Unable to decode key bundle during loading")
        }

        return (bundleArray[0], bundleArray[1])
    }

    func save(chainKeyData: Data, userId: String, groupId: String) throws {
        let url = StorageManager.getFileURL(from: String(format: chainKeyFileNameFormat, userId, groupId),
                                            with: fileExtension)

        do {
            try chainKeyData.write(to: url)
        } catch {
            throw SignalProtocolError(message: "Unable to save chain key")
        }
    }

    func loadChainKeyData(userId: String, groupId: String) throws -> Data {
        let url = StorageManager.getFileURL(from: String(format: chainKeyFileNameFormat, userId, groupId),
                                            with: fileExtension)

        guard let chainKeyData = try? Data(contentsOf: url) else {
            // Cannot find save file
            throw SignalProtocolError(message: "Unable to load chain key")
        }

        return chainKeyData
    }
}
