import Foundation
import SwiftUI

class LoginButtonViewModel {
    private var authHandler: ALAuthHandler
    var backgroundColor: Color {
        LoginButtonColor.getColor(type: authHandler.type)
    }

    init(authHandler: ALAuthHandler) {
        self.authHandler = authHandler
    }

    var text: String { "\(authHandler.type.rawValue)" }

    func tapped() {
        authHandler.initiateSignIn()
    }
}

struct LoginButtonColor {
    static func getColor(type: ALAuthHandlerType) -> Color {
        switch type {
        case .facebook:
            return ColorConstant.facebookButton
        case .google:
            return ColorConstant.googleButton
        }
    }
}

// MARK: Hashable
extension LoginButtonViewModel: Hashable {
    static func == (lhs: LoginButtonViewModel, rhs: LoginButtonViewModel) -> Bool {
        lhs.authHandler.type == rhs.authHandler.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(authHandler.type)
    }
}
