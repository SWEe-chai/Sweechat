import CryptoKit
import Foundation

struct SharedKeyImpl: SharedKey {
    let rawRepresentation: Data

    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    private var symmetricKey: SymmetricKey {
        SymmetricKey(data: rawRepresentation)
    }

    func encrypt(plaintext: Data) throws -> Data {
        do {
            let sealedBoxData = try ChaChaPoly.seal(plaintext, using: symmetricKey).combined
            let sealedBox = try ChaChaPoly.SealedBox(combined: sealedBoxData)
            return sealedBox.combined
        } catch {
            throw SignalError(message: "Unable to encrypt data")
        }
    }

    func decrypt(ciphertext: Data) throws -> Data {
        do {
            let decryptedData = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: ciphertext), using: symmetricKey)
            return decryptedData
        } catch {
            throw SignalError(message: "Unable to decrypt data")
        }
    }
}
