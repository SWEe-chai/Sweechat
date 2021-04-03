import CryptoKit
import Foundation

struct P256SharedKey: SharedKey {
    let rawRepresentation: Data

    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    private var symmetricKey: SymmetricKey {
        SymmetricKey(data: rawRepresentation)
    }

    func encrypt(plaintextData: Data) throws -> Data {
        do {
            let sealedBoxData = try ChaChaPoly.seal(plaintextData, using: symmetricKey).combined
            let sealedBox = try ChaChaPoly.SealedBox(combined: sealedBoxData)
            return sealedBox.combined
        } catch {
            throw SignalProtocolError(message: "Unable to encrypt data")
        }
    }

    func decrypt(ciphertextData: Data) throws -> Data {
        do {
            let decryptedData = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: ciphertextData), using: symmetricKey)
            return decryptedData
        } catch {
            throw SignalProtocolError(message: "Unable to decrypt data")
        }
    }
}
