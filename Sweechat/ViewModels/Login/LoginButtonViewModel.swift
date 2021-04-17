import SwiftUI

class LoginButtonViewModel {
    private var authHandler: ALAuthHandler

    var backgroundColor: Color {
        LoginButtonColor.getColor(type: authHandler.type)
    }

    var picture: String {
        authHandler.type.rawValue.lowercased()
    }

    var text: String {
        "\(authHandler.type.rawValue)"
    }

    // MARK: Initialization

    init(authHandler: ALAuthHandler) {
        self.authHandler = authHandler
    }

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
