import Foundation

protocol SharedKey: Key {
    func encrypt(plaintextData: Data) throws -> Data
    func decrypt(ciphertextData: Data) throws -> Data
}
