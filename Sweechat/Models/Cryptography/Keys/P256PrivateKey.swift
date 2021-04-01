import CryptoKit
import Foundation

struct P256PrivateKey: PrivateKey {
    let rawRepresentation: Data

    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    func combine(with publicKey: PublicKey, salt: Data, outputKeyLength: Int) throws -> SharedKey {
        do {
            let privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: rawRepresentation)
            let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: publicKey.rawRepresentation)
            let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data(),
                                                                    outputByteCount: outputKeyLength)
            var symmetricKeyBytes = Data()
            symmetricKey.withUnsafeBytes({ symmetricKeyBytes.append(contentsOf: $0) })
            return P256SharedKey(rawRepresentation: symmetricKeyBytes)
        } catch {
            throw SignalProtocolError(message: "Unable to combine keys")
        }
    }

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
