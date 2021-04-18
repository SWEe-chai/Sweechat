import Foundation

/**
 An interface representing a cryptographic public key.
 */
protocol PublicKey: Key {
    func isValidSignature(_ signature: Data, for data: Data) throws -> Bool
}
