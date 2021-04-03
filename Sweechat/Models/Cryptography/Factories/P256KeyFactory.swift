import CryptoKit
import Foundation

struct P256KeyFactory: KeyFactory {
    func generateKeyPair() -> (PrivateKey, PublicKey) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        return (P256PrivateKey(rawRepresentation: privateKey.rawRepresentation),
                P256PublicKey(rawRepresentation: publicKey.rawRepresentation))
    }

    func generatePrivateKey(from data: Data) -> PrivateKey {
        P256PrivateKey(rawRepresentation: data)
    }

    func generatePublicKey(from data: Data) -> PublicKey {
        P256PublicKey(rawRepresentation: data)
    }

    func generateSharedKey(from data: Data) -> SharedKey {
        P256SharedKey(rawRepresentation: data)
    }
}
