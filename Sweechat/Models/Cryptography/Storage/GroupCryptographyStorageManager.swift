import Foundation

protocol GroupCryptographyStorageManager {
    func save(userId: String, privateServerKeyBundle: [String: Data], publicServerKeyBundle: [String: Data]) throws
    func loadServerKeyBundles(userId: String) throws -> ([String: Data], [String: Data])?
    func save(chainKeyData: Data, userId: String, groupId: String) throws
    func loadChainKeyData(userId: String, groupId: String) throws -> Data
}
