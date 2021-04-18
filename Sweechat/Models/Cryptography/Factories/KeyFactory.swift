import Foundation

/**
 An interface for a cryptographic key generating factory.
 */
protocol KeyFactory {
    func generateKeyPair() -> (PrivateKey, PublicKey)
    func generatePrivateKey(from data: Data) -> PrivateKey
    func generatePublicKey(from data: Data) -> PublicKey
    func generateSharedKey(from data: Data) -> SharedKey
}
