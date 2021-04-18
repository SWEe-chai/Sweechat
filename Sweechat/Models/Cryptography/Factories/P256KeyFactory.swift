import CryptoKit
import Foundation

/**
 A representation of a factory that generates keys backed by NIST P-256 elliptic curves.
 */
struct P256KeyFactory: KeyFactory {
    /// Generates a random pair of private and public NIST P-256 elliptic curve cryptographic keys.
    /// - Returns: A random pair of private and public NIST P-256 elliptic curve cryptographic keys.
    func generateKeyPair() -> (PrivateKey, PublicKey) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        return (P256PrivateKey(rawRepresentation: privateKey.rawRepresentation),
                P256PublicKey(rawRepresentation: publicKey.rawRepresentation))
    }

    /// Generates a random private NIST P-256 elliptic curve cryptographic key.
    /// - Returns: A random private NIST P-256 elliptic curve cryptographic key.
    func generatePrivateKey(from data: Data) -> PrivateKey {
        P256PrivateKey(rawRepresentation: data)
    }

    /// Generates a random public NIST P-256 elliptic curve cryptographic key.
    /// - Returns: A random public NIST P-256 elliptic curve cryptographic key.
    func generatePublicKey(from data: Data) -> PublicKey {
        P256PublicKey(rawRepresentation: data)
    }

    /// Generates a random shared (symmetric) NIST P-256 elliptic curve cryptographic key.
    /// - Returns: A random shared (symmetric) NIST P-256 elliptic curve cryptographic key.
    func generateSharedKey(from data: Data) -> SharedKey {
        P256SharedKey(rawRepresentation: data)
    }
}
