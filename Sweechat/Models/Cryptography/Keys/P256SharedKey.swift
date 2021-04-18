import CryptoKit
import Foundation

/**
 A cryptographic shared (symmetric) key generated using NIST P-256 elliptic curves.
 */
struct P256SharedKey: SharedKey {
    let rawRepresentation: Data

    /// Constructs a `P256SharedKey` from the specified raw representation.
    init(rawRepresentation: Data) {
        self.rawRepresentation = rawRepresentation
    }

    private var symmetricKey: SymmetricKey {
        SymmetricKey(data: rawRepresentation)
    }

    /// Returns the ciphertext data from encrypting the specified plaintext data using this key.
    /// - Parameters:
    ///   - plaintextData: The specified plaintext data.
    /// - Returns: The ciphertext data from encrypting the specified plaintext data using this key.
    /// - Throws: A `SignalProtocolError` if an error occurs during encryption.
    func encrypt(plaintextData: Data) throws -> Data {
        do {
            let sealedBoxData = try ChaChaPoly.seal(plaintextData, using: symmetricKey).combined
            let sealedBox = try ChaChaPoly.SealedBox(combined: sealedBoxData)
            return sealedBox.combined
        } catch {
            throw SignalProtocolError(message: "Unable to encrypt data")
        }
    }

    /// Returns the plaintext data from decrypting the specified ciphertext data using this key.
    /// - Parameters:
    ///   - ciphertextData: The specified ciphertext data.
    /// - Returns: The plaintext data from decrypting the specified ciphertext data using this key.
    /// - Throws: A `SignalProtocolError` if an error occurs during decryption.
    func decrypt(ciphertextData: Data) throws -> Data {
        do {
            let decryptedData = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: ciphertextData), using: symmetricKey)
            return decryptedData
        } catch {
            throw SignalProtocolError(message: "Unable to decrypt data")
        }
    }
}
