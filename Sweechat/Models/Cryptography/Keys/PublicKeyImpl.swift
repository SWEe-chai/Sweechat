import CryptoKit
import Foundation

struct PublicKeyImpl: PublicKey {
    let rawRepresentation: Data

    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    func isValidSignature(_ signature: Data, for data: Data) throws -> Bool {
        do {
            let signingKey = try P256.Signing.PublicKey(rawRepresentation: rawRepresentation)
            let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
            return signingKey.isValidSignature(ecdsaSignature, for: data)
        } catch {
            throw SignalError(message: "Unable to verify signature using key")
        }
    }
}
