import Foundation

/// An interface through which the server communicates with the calling `User` instance.
protocol UserFacadeDelegate: AnyObject {
    /// Updates the calling `User` instance with information from the specified `User`.
    /// - Parameters:
    ///   - user: The specified `User`.
    func update(user: User)
}
