import CryptoKit
import Foundation

protocol CryptographyProvider {
    func generateSenderKeyBundles() throws -> ([String: Data], [String: Data])
    func generateReceiverKeyBundles(fromSenderKeyBundle keyBundle: [String: Data]) throws -> ([String: Data],
                                                                                              [String: Data])
    func generateSenderMasterKeyData(privateKeyBundle: [String: Data], publicKeyBundle: [String: Data]) throws -> Data
    func generateReceiverMasterKeyData(privateKeyBundle: [String: Data], publicKeyBundle: [String: Data]) throws -> Data
    func encrypt(plaintext: Data, withKeyData keyData: Data) throws -> Data
    func decrypt(ciphertext: Data, withKeyData keyData: Data) throws -> Data
}
