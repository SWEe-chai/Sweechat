import Foundation

class LoginButtonViewModel {
    private var authHandler: ALAuthHandler

    init(authHandler: ALAuthHandler) {
        self.authHandler = authHandler
    }

    var text: String { "\(authHandler.type.rawValue) Login" }

    func tapped() {
        authHandler.initiateSignIn()
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
