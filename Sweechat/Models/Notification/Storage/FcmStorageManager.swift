/**
 An interface for storing Firebase cloud messaging tokens.
 */
protocol FcmStorageManager {
    static func save(token: String?) throws
}
