import Foundation

protocol PublicKey: Key {
    func isValidSignature(_ signature: Data, for data: Data) throws -> Bool
}
