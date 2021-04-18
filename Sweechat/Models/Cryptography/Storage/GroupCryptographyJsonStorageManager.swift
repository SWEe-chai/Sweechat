import Foundation

/**
 A JSON-based storage manager for the group cryptography library.
 */
struct GroupCryptographyJsonStorageManager: GroupCryptographyStorageManager {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let serverKeyBundlesFileNameFormat = "%@_serverKeyBundles"
    private let chainKeyFileNameFormat = "%@_%@_chainKeys"
    private let fileExtension = ".json"

    /// Saves the specified server key bundles for the specified user ID.
    /// - Parameters:
    ///   - userId: The specified user ID.
    ///   - privateServerKeyBundle: The specified private server key bundle.
    ///   - publicServerKeyBundle: The specified public server key bundle.
    /// - Throws: A `SignalProtocolError` if an error occurs while saving.
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

    /// Loads and returns the server key bundles for the specified user ID.
    /// - Parameters:
    ///   - userId: The specified user ID.
    /// - Returns: The server key bundles for the specified user ID, or nil if the bundles cannot be loaded.
    /// - Throws: A `SignalProtocolError` if an error occurs while loading.
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

    /// Saves the specified chain key data for the specified user ID and group ID.
    /// - Parameters:
    ///   - chainKeyData: The specified chain key data.
    ///   - userId: The specified user ID.
    ///   - groupId: The specified group ID.
    /// - Throws: A `SignalProtocolError` if an error occurs while saving.
    func save(chainKeyData: Data, userId: String, groupId: String) throws {
        let url = StorageManager.getFileURL(from: String(format: chainKeyFileNameFormat, userId, groupId),
                                            with: fileExtension)

        do {
            try chainKeyData.write(to: url)
        } catch {
            throw SignalProtocolError(message: "Unable to save chain key")
        }
    }

    /// Loads and returns the chain key data for the specified user ID and group ID.
    /// - Parameters:
    ///   - userId: The specified user ID.
    ///   - groupId: The specified group ID.
    /// - Returns: The chain key data for the specified user ID and group ID.
    /// - Throws: A `SignalProtocolError` if an error occurs while loading.
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
