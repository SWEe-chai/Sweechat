import CryptoKit
import Foundation

protocol GroupCryptographyProvider {
    func getPublicServerKeyBundleData() throws -> Data
    mutating func generateKeyExchangeDataFrom(serverKeyBundleData: Data, groupId: String) throws -> Data
    mutating func process(keyExchangeBundleData: Data, groupId: String) throws
    func encrypt(plaintextData: Data, groupId: String) throws -> Data
    func decrypt(ciphertextData: Data, groupId: String) throws -> Data
}
