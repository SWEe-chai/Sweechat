import SwiftUI

protocol ALAuthHandler: AnyObject {
    var type: ALAuthHandlerType { get }
    var delegate: ALAuthHandlerDelegate? { get set }
    func initiateSignIn()
}
