import CryptoKit
import Foundation

protocol GroupCryptographyProvider {
    func getPublicServerKeyBundleData() throws -> Data
    mutating func generateKeyExchangeDataFrom(serverKeyBundleData: Data) throws -> Data
    mutating func process(keyExchangeBundleData: Data) throws
    func encrypt(plaintextData: Data) throws -> Data
    func decrypt(ciphertextData: Data) throws -> Data
}
