import CryptoKit
import Foundation

struct CryptographyProviderImpl: CryptographyProvider {
    private let outputKeyLength = 32
    private let salt = "Signal Protocol".data(using: .utf8)!
    let keyFactory: KeyFactory

    func generateSenderKeyBundles() throws -> ([String: Data], [String: Data]) {

        // Generate required key pairs
        let (privateIdentityKey, publicIdentityKey) = keyFactory.generateKeyPair()
        let (privateSignedPreKey, publicSignedPreKey) = keyFactory.generateKeyPair()
        let (privateOneUsePreKey, publicOneUsePreKey) = keyFactory.generateKeyPair()

        // Sign pre-key
        let dataToSign = publicSignedPreKey.rawRepresentation
        let signature = try privateIdentityKey.sign(data: dataToSign)

        // Generate private key bundle
        var privateKeyBundle: [String: Data] = [:]
        privateKeyBundle["ipk"] = privateIdentityKey.rawRepresentation
        privateKeyBundle["spk"] = privateSignedPreKey.rawRepresentation
        privateKeyBundle["opk"] = privateOneUsePreKey.rawRepresentation

        // Generate public key bundle
        var publicKeyBundle: [String: Data] = [:]
        publicKeyBundle["ipk"] = publicIdentityKey.rawRepresentation
        publicKeyBundle["spk"] = publicSignedPreKey.rawRepresentation
        publicKeyBundle["opk"] = publicOneUsePreKey.rawRepresentation
        publicKeyBundle["signature"] = signature

        return (privateKeyBundle, publicKeyBundle)
    }

    func generateReceiverKeyBundles(fromSenderKeyBundle keyBundle: [String: Data]) throws
            -> ([String: Data], [String: Data]) {

        // Get bundle data for verifying sender's signature
        guard let senderIdentityKeyData = keyBundle["ipk"],
              let senderSignedPreKeyData = keyBundle["spk"],
              let signature = keyBundle["signature"] else {
            throw SignalError(message: "Missing identity key from sender key bundle")
        }

        // Verify sender's signature
        let senderIdentityKey = keyFactory.generatePublicKey(from: senderIdentityKeyData)
        guard try senderIdentityKey.isValidSignature(signature, for: senderSignedPreKeyData) else {
            throw SignalError(message: "Signature could not be verified")
        }

        // Generate required key pairs
        let (privateIdentityKey, publicIdentityKey) = keyFactory.generateKeyPair()
        let (privateEphemeralKey, publicEphemeralKey) = keyFactory.generateKeyPair()

        // Generate private key bundle
        var privateKeyBundle: [String: Data] = [:]
        privateKeyBundle["ipk"] = privateIdentityKey.rawRepresentation
        privateKeyBundle["epk"] = privateEphemeralKey.rawRepresentation

        // Generate public key bundle
        var publicKeyBundle: [String: Data] = [:]
        publicKeyBundle["ipk"] = publicIdentityKey.rawRepresentation
        publicKeyBundle["epk"] = publicEphemeralKey.rawRepresentation

        return (privateKeyBundle, publicKeyBundle)
    }

    func generateSenderMasterKeyData(privateKeyBundle: [String: Data],
                                     publicKeyBundle: [String: Data]) throws -> Data {

        // Get bundle data for generating sender's master key
        guard let receiverPublicIdentityKeyData = publicKeyBundle["ipk"],
              let receiverPublicEphemeralKeyData = publicKeyBundle["epk"],
              let senderPrivateIdentityKeyData = privateKeyBundle["ipk"],
              let senderPrivateSignedPreKeyData = privateKeyBundle["spk"],
              let senderPrivateOneUsePreKeyData = privateKeyBundle["opk"] else {
            throw SignalError(message: "Unable to retrieve bundle key data to generate sender master key")
        }

        // Generate bundle keys from bundle data
        let receiverPublicIdentityKey = keyFactory.generatePublicKey(from: receiverPublicIdentityKeyData)
        let receiverPublicEphemeralKey = keyFactory.generatePublicKey(from: receiverPublicEphemeralKeyData)
        let senderPrivateIdentityKey = keyFactory.generatePrivateKey(from: senderPrivateIdentityKeyData)
        let senderPrivateSignedPreKey = keyFactory.generatePrivateKey(from: senderPrivateSignedPreKeyData)
        let senderPrivateOneUsePreKey = keyFactory.generatePrivateKey(from: senderPrivateOneUsePreKeyData)

        // Combine key pairs and use them to derive sender's master key
        guard let key1 = try? senderPrivateSignedPreKey.combine(with: receiverPublicIdentityKey, salt: salt,
                                                                outputKeyLength: outputKeyLength),
              let key2 = try? senderPrivateIdentityKey.combine(with: receiverPublicEphemeralKey, salt: salt,
                                                               outputKeyLength: outputKeyLength),
              let key3 = try? senderPrivateSignedPreKey.combine(with: receiverPublicEphemeralKey, salt: salt,
                                                                outputKeyLength: outputKeyLength),
              let key4 = try? senderPrivateOneUsePreKey.combine(with: receiverPublicEphemeralKey, salt: salt,
                                                                outputKeyLength: outputKeyLength) else {
            throw SignalError(message: "Unable to generate sender keys from key bundle data")
        }
        let masterKey = keyDerivationFunction(keys: [key1, key2, key3, key4], outputKeyLength: outputKeyLength)
        return masterKey.rawRepresentation
    }

    func generateReceiverMasterKeyData(privateKeyBundle: [String: Data],
                                       publicKeyBundle: [String: Data]) throws -> Data {

        // Get bundle data for generating receiver's master key
        guard let receiverPrivateIdentityKeyData = privateKeyBundle["ipk"],
              let receiverPrivateEphemeralKeyData = privateKeyBundle["epk"],
              let senderPublicIdentityKeyData = publicKeyBundle["ipk"],
              let senderPublicSignedPreKeyData = publicKeyBundle["spk"],
              let senderPublicOneUsePreKeyData = publicKeyBundle["opk"] else {
            throw SignalError(message: "Unable to retrieve bundle key data to generate receiver master key")
        }

        // Generate bundle keys from bundle data
        let receiverPrivateIdentityKey = keyFactory.generatePrivateKey(from: receiverPrivateIdentityKeyData)
        let receiverPrivateEphemeralKey = keyFactory.generatePrivateKey(from: receiverPrivateEphemeralKeyData)
        let senderPublicIdentityKey = keyFactory.generatePublicKey(from: senderPublicIdentityKeyData)
        let senderPublicSignedPreKey = keyFactory.generatePublicKey(from: senderPublicSignedPreKeyData)
        let senderPublicOneUsePreKey = keyFactory.generatePublicKey(from: senderPublicOneUsePreKeyData)

        // Combine key pairs and use them to derive receiver's master key
        guard let key1 = try? receiverPrivateIdentityKey.combine(with: senderPublicSignedPreKey, salt: salt,
                                                                 outputKeyLength: outputKeyLength),
              let key2 = try? receiverPrivateEphemeralKey.combine(with: senderPublicIdentityKey, salt: salt,
                                                                  outputKeyLength: outputKeyLength),
              let key3 = try? receiverPrivateEphemeralKey.combine(with: senderPublicSignedPreKey, salt: salt,
                                                                  outputKeyLength: outputKeyLength),
              let key4 = try? receiverPrivateEphemeralKey.combine(with: senderPublicOneUsePreKey, salt: salt,
                                                                  outputKeyLength: outputKeyLength) else {
            throw SignalError(message: "Unable to generate receiver keys from key bundle data")
        }
        let masterKey = keyDerivationFunction(keys: [key1, key2, key3, key4], outputKeyLength: outputKeyLength)
        return masterKey.rawRepresentation
    }

    private func keyDerivationFunction(keys: [SharedKey], outputKeyLength: Int) -> SharedKey {
        var combinedData = Data()
        for key in keys {
            combinedData.append(SymmetricKey(data: key.rawRepresentation).rawRepresentation)
        }
        let concatenatedKey = SymmetricKey(data: combinedData)
        let derivedKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: concatenatedKey, info: Data(),
                                                outputByteCount: outputKeyLength)
        return keyFactory.generateSharedKey(from: derivedKey.rawRepresentation)
    }

    func encrypt(plaintext: Data, withKeyData keyData: Data) throws -> Data {
        let key = keyFactory.generateSharedKey(from: keyData)
        return try key.encrypt(plaintext: plaintext)
    }

    func decrypt(ciphertext: Data, withKeyData keyData: Data) throws -> Data {
        let key = keyFactory.generateSharedKey(from: keyData)
        return try key.decrypt(ciphertext: ciphertext)
    }
}

extension SymmetricKey {
    var rawRepresentation: Data {
        var data = Data()
        withUnsafeBytes({ data.append(contentsOf: $0) })
        return data
    }
}
