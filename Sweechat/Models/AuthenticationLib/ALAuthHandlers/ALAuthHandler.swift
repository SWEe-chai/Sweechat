//
//  AuthHandler.swift
//  SlackersTest
//
//  Created by Hai Nguyen on 12/3/21.
//

import Foundation
import SwiftUI

protocol ALAuthHandler: AnyObject {
    var delegate: ALAuthHandlerDelegate? { get set }
    func initiateSignIn()
}
