import CryptoKit
import Foundation

struct SignalProtocol: GroupCryptographyProvider {
    private let userId: String
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let keyFactory: KeyFactory
    private let storageManager: GroupCryptographyJsonStorageManager
    private var privateServerKeyBundle: [String: Data] = [:]
    private var publicServerKeyBundle: [String: Data] = [:]

    private static let keyLength = 32
    private static let salt = "Signal Protocol".data(using: .utf8)!
    private static let identityKeyDictionaryKey = "ik"
    private static let signedPreKeyDictionaryKey = "spk"
    private static let ephemeralKeyDictionaryKey = "ek"
    private static let chainKeyDictionaryKey = "ck"
    private static let signatureDictionaryKey = "signature"

    init(userId: String) {
        self.userId = userId
        self.keyFactory = P256KeyFactory()
        self.storageManager = GroupCryptographyJsonStorageManager()
        initialiseServerKeyBundles()
    }

    // MARK: getPublicServerKeyBundleData

    func getPublicServerKeyBundleData() throws -> Data {
        try encode(keyBundle: publicServerKeyBundle)
    }

    // MARK: generateKeyExchangeDataFrom

    mutating func generateKeyExchangeDataFrom(serverKeyBundleData: Data, groupId: String) throws -> Data {
        // Generate server keys
        let (serverIdentityKey,
             serverSignedPreKey,
             signature) = try getPublicCredentialsFrom(serverKeyBundleData: serverKeyBundleData)

        // Verify signature
        try verifySignature(signature, using: serverIdentityKey, for: serverSignedPreKey.rawRepresentation)

        // Generate own keys
        let (privateIdentityKey, publicIdentityKey) = try getIdentityKeyPair()
        let (privateEphemeralKey, publicEphemeralKey) = try generateEphemeralKeyPair()

        // Generate master key
        let masterKey = try generateInitiatorMasterKey(privateIdentityKey: privateIdentityKey,
                                                       privateEphemeralKey: privateEphemeralKey,
                                                       serverIdentityKey: serverIdentityKey,
                                                       serverSignedPreKey: serverSignedPreKey)

        // Generate chain key
        let chainKey = try getOrGenerateChainKey(groupId: groupId)

        // Encrypt-then-sign chain key
        let (encryptedChainKeyData, chainKeySignature) = try encryptThenSign(encryptionKey: masterKey,
                                                                             signingKey: privateIdentityKey,
                                                                             data: chainKey.rawRepresentation)

        // Generate key exchange data
        let keyExchangeBundle = generateKeyExchangeBundle(publicIdentityKey: publicIdentityKey,
                                                          publicEphemeralKey: publicEphemeralKey,
                                                          signature: chainKeySignature,
                                                          encryptedChainKeyData: encryptedChainKeyData)

        // Encode key exchange data
        let keyExchangeBundleData = try encode(keyBundle: keyExchangeBundle)

        return keyExchangeBundleData
    }

    // MARK: process

    mutating func process(keyExchangeBundleData: Data, groupId: String) throws {
        // Generate key exchange keys
        let (keyExchangeIdentityKey,
             keyExchangeEphemeralKey,
             encryptedKeyExchangeChainKeyData,
             signature) = try getPublicCredentialsFrom(keyExchangeBundleData: keyExchangeBundleData)

        // Verify signature
        try verifySignature(signature, using: keyExchangeIdentityKey, for: encryptedKeyExchangeChainKeyData)

        // Generate own keys
        let (privateIdentityKey, privateSignedPreKey) = try getPrivateIdentityAndSignedPreKeys()

        // Generate master key
        let masterKey = try generateReceiverMasterKey(identityKey: privateIdentityKey,
                                                      signedPreKey: privateSignedPreKey,
                                                      keyExchangeIdentityKey: keyExchangeIdentityKey,
                                                      keyExchangeEphemeralKey: keyExchangeEphemeralKey)

        // Decrypt chain key
        let chainKey = try decryptChainKey(encryptedKeyExchangeChainKeyData, using: masterKey)

        // Store chain key
        try storageManager.save(chainKeyData: chainKey.rawRepresentation, userId: userId, groupId: groupId)
    }

    // MARK: encrypt

    func encrypt(plaintextData: Data, groupId: String) throws -> Data {
        let chainKey = try getOrGenerateChainKey(groupId: groupId)
        let ciphertextData = try chainKey.encrypt(plaintextData: plaintextData)
        return ciphertextData
    }

    // MARK: decrypt

    func decrypt(ciphertextData: Data, groupId: String) throws -> Data {
        let chainKey = try getOrGenerateChainKey(groupId: groupId)
        let ciphertextData = try chainKey.decrypt(ciphertextData: ciphertextData)
        return ciphertextData
    }

    // MARK: Helper functions

    private mutating func initialiseServerKeyBundles() {
        if let (privateServerKeyBundle,
                publicServerKeyBundle) = try? storageManager.loadServerKeyBundles(userId: userId) {
            self.privateServerKeyBundle = privateServerKeyBundle
            self.publicServerKeyBundle = publicServerKeyBundle
            return
        }

        let (privateIdentityKey, publicIdentityKey) = keyFactory.generateKeyPair()
        let (privateSignedPreKey, publicSignedPreKey) = keyFactory.generateKeyPair()

        guard let signature = try? privateIdentityKey.sign(data: publicSignedPreKey.rawRepresentation) else {
            fatalError("Unable to sign signed pre-key")
        }

        privateServerKeyBundle[SignalProtocol.identityKeyDictionaryKey] = privateIdentityKey.rawRepresentation
        privateServerKeyBundle[SignalProtocol.signedPreKeyDictionaryKey] = privateSignedPreKey.rawRepresentation
        publicServerKeyBundle[SignalProtocol.identityKeyDictionaryKey] = publicIdentityKey.rawRepresentation
        publicServerKeyBundle[SignalProtocol.signedPreKeyDictionaryKey] = publicSignedPreKey.rawRepresentation
        publicServerKeyBundle[SignalProtocol.signatureDictionaryKey] = signature

        do {
            try storageManager.save(userId: userId, privateServerKeyBundle: privateServerKeyBundle,
                                    publicServerKeyBundle: publicServerKeyBundle)
        } catch {
            fatalError("Unable to save server key bundles")
        }
    }

    private func encode(keyBundle: [String: Data]) throws -> Data {
        guard let encodedKeyBundle = try? jsonEncoder.encode(keyBundle) else {
            throw SignalProtocolError(message: "Unable to encode key bundle")
        }

        return encodedKeyBundle
    }

    private func getPublicCredentialsFrom(serverKeyBundleData: Data) throws -> (PublicKey, PublicKey, Data) {
        guard let serverKeyBundle = try? jsonDecoder.decode([String: Data].self, from: serverKeyBundleData) else {
            throw SignalProtocolError(message: "Unable to decode server key bundle data")
        }

        guard let identityKeyData = serverKeyBundle[SignalProtocol.identityKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Missing identity key data from server key bundle")
        }
        guard let signedPreKeyData = serverKeyBundle[SignalProtocol.signedPreKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Missing signed pre-key key data from server key bundle")
        }
        guard let signature = serverKeyBundle[SignalProtocol.signatureDictionaryKey] else {
            throw SignalProtocolError(message: "Missing signature from server key bundle")
        }

        let identityKey = keyFactory.generatePublicKey(from: identityKeyData)
        let signedPreKey = keyFactory.generatePublicKey(from: signedPreKeyData)

        return (identityKey, signedPreKey, signature)
    }

    private func verifySignature(_ signature: Data, using key: PublicKey, for data: Data) throws {
        guard try key.isValidSignature(signature, for: data) else {
            throw SignalProtocolError(message: "Could not verify signature for data")
        }
    }

    private func getIdentityKeyPair() throws -> (PrivateKey, PublicKey) {
        guard let privateIdentityKeyData = privateServerKeyBundle[SignalProtocol.identityKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Unable to get own private identity key")
        }
        guard let publicIdentityKeyData = publicServerKeyBundle[SignalProtocol.identityKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Unable to get own public identity key")
        }

        let privateIdentityKey = keyFactory.generatePrivateKey(from: privateIdentityKeyData)
        let publicIdentityKey = keyFactory.generatePublicKey(from: publicIdentityKeyData)

        return (privateIdentityKey, publicIdentityKey)
    }

    private func generateEphemeralKeyPair() throws -> (PrivateKey, PublicKey) {
        let (privateEphemeralKey, publicEphemeralKey) = keyFactory.generateKeyPair()
        return (privateEphemeralKey, publicEphemeralKey)
    }

    private func generateInitiatorMasterKey(privateIdentityKey: PrivateKey, privateEphemeralKey: PrivateKey,
                                            serverIdentityKey: PublicKey,
                                            serverSignedPreKey: PublicKey) throws -> SharedKey {
        guard let key1 = try? privateIdentityKey.combine(with: serverSignedPreKey, salt: SignalProtocol.salt,
                                                         outputKeyLength: SignalProtocol.keyLength),
              let key2 = try? privateEphemeralKey.combine(with: serverIdentityKey, salt: SignalProtocol.salt,
                                                          outputKeyLength: SignalProtocol.keyLength),
              let key3 = try? privateEphemeralKey.combine(with: serverSignedPreKey, salt: SignalProtocol.salt,
                                                          outputKeyLength: SignalProtocol.keyLength) else {
            throw SignalProtocolError(message: "Unable to generate requisite keys for initiator master key")
        }
        let masterKey = keyDerivationFunction(keys: [key1, key2, key3], outputKeyLength: SignalProtocol.keyLength)
        return masterKey
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

    private func encryptThenSign(encryptionKey: SharedKey, signingKey: PrivateKey, data: Data) throws -> (Data, Data) {
        guard let encryptedData = try? encryptionKey.encrypt(plaintextData: data) else {
            throw SignalProtocolError(message: "Unable to encrypt data")
        }
        guard let signature = try? signingKey.sign(data: encryptedData) else {
            throw SignalProtocolError(message: "Unable to sign data")
        }

        return (encryptedData, signature)
    }

    private func generateKeyExchangeBundle(publicIdentityKey: PublicKey, publicEphemeralKey: PublicKey,
                                           signature: Data, encryptedChainKeyData: Data) -> [String: Data] {
        var keyExchangeBundle: [String: Data] = [:]

        keyExchangeBundle[SignalProtocol.identityKeyDictionaryKey] = publicIdentityKey.rawRepresentation
        keyExchangeBundle[SignalProtocol.ephemeralKeyDictionaryKey] = publicEphemeralKey.rawRepresentation
        keyExchangeBundle[SignalProtocol.chainKeyDictionaryKey] = encryptedChainKeyData
        keyExchangeBundle[SignalProtocol.signatureDictionaryKey] = signature

        return keyExchangeBundle
    }

    private func getPublicCredentialsFrom(keyExchangeBundleData: Data) throws -> (PublicKey, PublicKey, Data, Data) {
        guard let keyExchangeBundle = try? jsonDecoder.decode([String: Data].self, from: keyExchangeBundleData) else {
            throw SignalProtocolError(message: "Unable to decode key exchange key bundle data")
        }
        guard let keyExchangeIdentityKeyData = keyExchangeBundle[SignalProtocol.identityKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Missing identity key data from key exchange bundle")
        }
        guard let keyExchangeEphemeralKeyData = keyExchangeBundle[SignalProtocol.ephemeralKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Missing ephemeral key data from key exchange bundle")
        }
        guard let encryptedKeyExchangeChainKeyData = keyExchangeBundle[SignalProtocol.chainKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Missing chain key data from key exchange bundle")
        }
        guard let signature = keyExchangeBundle[SignalProtocol.signatureDictionaryKey] else {
            throw SignalProtocolError(message: "Missing signature from key exchange bundle")
        }

        let keyExchangeIdentityKey = keyFactory.generatePublicKey(from: keyExchangeIdentityKeyData)
        let keyExchangeEphemeralKey = keyFactory.generatePublicKey(from: keyExchangeEphemeralKeyData)

        return (keyExchangeIdentityKey, keyExchangeEphemeralKey, encryptedKeyExchangeChainKeyData, signature)
    }

    private func generateReceiverMasterKey(identityKey: PrivateKey, signedPreKey: PrivateKey,
                                           keyExchangeIdentityKey: PublicKey,
                                           keyExchangeEphemeralKey: PublicKey) throws -> SharedKey {
        guard let key1 = try? signedPreKey.combine(with: keyExchangeIdentityKey, salt: SignalProtocol.salt,
                                                   outputKeyLength: SignalProtocol.keyLength),
              let key2 = try? identityKey.combine(with: keyExchangeEphemeralKey, salt: SignalProtocol.salt,
                                                  outputKeyLength: SignalProtocol.keyLength),
              let key3 = try? signedPreKey.combine(with: keyExchangeEphemeralKey, salt: SignalProtocol.salt,
                                                   outputKeyLength: SignalProtocol.keyLength) else {
            throw SignalProtocolError(message: "Unable to generate requisite keys for receiver master key")
        }

        let masterKey = keyDerivationFunction(keys: [key1, key2, key3], outputKeyLength: SignalProtocol.keyLength)
        return masterKey
    }

    private func getPrivateIdentityAndSignedPreKeys() throws -> (PrivateKey, PrivateKey) {
        guard let identityKeyData = privateServerKeyBundle[SignalProtocol.identityKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Unable to get private server identity key data")
        }
        guard let signedPreKeyData = privateServerKeyBundle[SignalProtocol.signedPreKeyDictionaryKey] else {
            throw SignalProtocolError(message: "Unable to get private signed pre-key key data")
        }

        let identityKey = keyFactory.generatePrivateKey(from: identityKeyData)
        let signedPreKey = keyFactory.generatePrivateKey(from: signedPreKeyData)

        return (identityKey, signedPreKey)
    }

    private func decryptChainKey(_ encryptedChainKeyData: Data, using key: SharedKey) throws -> SharedKey {
        guard let chainKeyData = try? key.decrypt(ciphertextData: encryptedChainKeyData) else {
            throw SignalProtocolError(message: "Unable to decryt chain key data")
        }

        let chainKey = keyFactory.generateSharedKey(from: chainKeyData)
        return chainKey
    }

    private func getOrGenerateChainKey(groupId: String) throws -> SharedKey {
        if let chainKeyData = try? storageManager.loadChainKeyData(userId: userId, groupId: groupId) {
            // Chain key already stored
            return keyFactory.generateSharedKey(from: chainKeyData)
        }

        let (randomPrivateKey, randomPublicKey) = keyFactory.generateKeyPair()

        guard let chainKey = try? randomPrivateKey.combine(with: randomPublicKey, salt: SignalProtocol.salt,
                                                           outputKeyLength: SignalProtocol.keyLength) else {
            throw SignalProtocolError(message: "Unable to generate chain key")
        }

        do {
            try storageManager.save(chainKeyData: chainKey.rawRepresentation, userId: userId, groupId: groupId)
        } catch {
            throw SignalProtocolError(message: "Unable to save")
        }

        return chainKey
    }
}

extension SymmetricKey {
    var rawRepresentation: Data {
        var data = Data()
        withUnsafeBytes({ data.append(contentsOf: $0) })
        return data
    }
}
