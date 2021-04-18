import Foundation

/**
 An interface representing a cryptographic private key.
 */
protocol PrivateKey: Key {
    func sign(data: Data) throws -> Data
    func combine(with publicKey: PublicKey, salt: Data, outputKeyLength: Int) throws -> SharedKey
}
