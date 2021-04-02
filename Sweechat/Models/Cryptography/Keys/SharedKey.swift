import Foundation

protocol SharedKey: Key {
    func encrypt(plaintext: Data) throws -> Data
    func decrypt(ciphertext: Data) throws -> Data
}
