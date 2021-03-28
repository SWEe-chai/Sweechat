import CryptoKit
import Foundation

struct KeyFactoryImpl: KeyFactory {
    func generateKeyPair() -> (PrivateKey, PublicKey) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        return (PrivateKeyImpl(rawRepresentation: privateKey.rawRepresentation),
                PublicKeyImpl(rawRepresentation: publicKey.rawRepresentation))
    }

    func generatePrivateKey(from data: Data) -> PrivateKey {
        PrivateKeyImpl(rawRepresentation: data)
    }

    func generatePublicKey(from data: Data) -> PublicKey {
        PublicKeyImpl(rawRepresentation: data)
    }

    func generateSharedKey(from data: Data) -> SharedKey {
        SharedKeyImpl(rawRepresentation: data)
    }
}
