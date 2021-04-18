/**
 A representation of an error that occurs in the cryptography library.
 */
class SignalProtocolError: Error {
    let message: String

    /// Constructs an instance of `SignalProtocolError` based on the specified message.
    init(message: String) {
        self.message = message
    }
}
