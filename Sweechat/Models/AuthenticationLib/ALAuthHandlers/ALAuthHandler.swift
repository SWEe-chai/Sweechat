import SwiftUI

protocol ALAuthHandler: AnyObject {
    var delegate: ALAuthHandlerDelegate? { get set }
    func initiateSignIn()
}
