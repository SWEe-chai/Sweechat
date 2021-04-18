/**
 An interface for communicating with third-party authentication providers.
 */
protocol ALAuthHandler: AnyObject {
    var type: ALAuthHandlerType { get }
    var delegate: ALAuthHandlerDelegate? { get set }
    func initiateSignIn()
}
