import CryptoKit
import Foundation

/**
 A cryptographic public key generated using NIST P-256 elliptic curves.
 */
struct P256PublicKey: PublicKey {
    let rawRepresentation: Data

    /// Constructs a `P256PublicKey` from the specified raw representation.
    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    /// Returns true if the specified signature is valid for the specified data.
    /// - Parameters:
    ///   - signature: The specified signature.
    ///   - data: The specified data.
    /// - Returns: true if the specified signature is valid for the specified data.
    /// - Throws: A `SignalProtocolError` if there is an error during signature verification.
    func isValidSignature(_ signature: Data, for data: Data) throws -> Bool {
        do {
            let signingKey = try P256.Signing.PublicKey(rawRepresentation: rawRepresentation)
            let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
            return signingKey.isValidSignature(ecdsaSignature, for: data)
        } catch {
            throw SignalProtocolError(message: "Unable to verify signature using key")
        }
    }
}
