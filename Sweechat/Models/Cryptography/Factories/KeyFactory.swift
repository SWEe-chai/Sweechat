import Foundation

protocol KeyFactory {
    func generateKeyPair() -> (PrivateKey, PublicKey)
    func generatePrivateKey(from data: Data) -> PrivateKey
    func generatePublicKey(from data: Data) -> PublicKey
    func generateSharedKey(from data: Data) -> SharedKey
}
