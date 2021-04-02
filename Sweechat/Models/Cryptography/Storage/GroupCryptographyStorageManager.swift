import Foundation

protocol GroupCryptographyStorageManager {
    func save(userId: String, privateServerKeyBundle: [String: Data], publicServerKeyBundle: [String: Data]) throws
    func loadServerKeyBundles(userId: String) throws -> ([String: Data], [String: Data])?
}
