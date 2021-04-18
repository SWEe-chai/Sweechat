import Foundation

/**
 An interface representing a cryptographic key.
 */
protocol Key {
    var rawRepresentation: Data { get }
}
