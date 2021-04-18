import Foundation

/**
 An interface representing a cryptographic shared (symmetric) key.
 */
protocol SharedKey: Key {
    func encrypt(plaintextData: Data) throws -> Data
    func decrypt(ciphertextData: Data) throws -> Data
}
