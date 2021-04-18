import CryptoKit
import Foundation

/**
 A cryptographic private key generated using NIST P-256 elliptic curves.
 */
struct P256PrivateKey: PrivateKey {
    let rawRepresentation: Data

    /// Constructs a `P256PrivateKey` from the specified raw representation.
    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    /// Combines the specified `PublicKey` with this `PrivateKey` using the specified salt and output key length
    /// to form a `SharedKey`.
    /// - Parameters:
    ///   - publicKey: The specified `PublicKey`.
    ///   - salt: The specified salt.
    ///   - outputKeyLength: The specified output key length.
    /// - Returns: A `SharedKey` based on the result of the combination operation.
    /// - Throws: A `SignalProtocolError` if an error occurs during combination.
    func combine(with publicKey: PublicKey, salt: Data, outputKeyLength: Int) throws -> SharedKey {
        do {
            let privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: rawRepresentation)
            let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: publicKey.rawRepresentation)
            let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
                                                                    salt: salt,
                                                                    sharedInfo: Data(),
                                                                    outputByteCount: outputKeyLength)
            var symmetricKeyBytes = Data()
            symmetricKey.withUnsafeBytes({ symmetricKeyBytes.append(contentsOf: $0) })
            return P256SharedKey(rawRepresentation: symmetricKeyBytes)
        } catch {
            throw SignalProtocolError(message: "Unable to combine keys")
        }
    }

    /// Returns the signature from signing the specified data with this key.
    /// - Parameters:
    ///   - data: The specified data.
    /// - Returns: The signature from signing the specified data with this key.
    /// - Throws: A `SignalProtocolError` if there is an error during signing.
    func sign(data: Data) throws -> Data {
        do {
            let signingKey = try P256.Signing.PrivateKey(rawRepresentation: rawRepresentation)
            let signature = try signingKey.signature(for: data)
            return signature.rawRepresentation
        } catch {
            throw SignalProtocolError(message: "Unable to sign using key")
        }
    }
}
