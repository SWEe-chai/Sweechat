import Combine
import os

class AppViewModel: ObservableObject {
    var loginViewModel: LoginViewModel {
        let viewModel = LoginViewModel()
        viewModel.delegate = self
        return viewModel
    }

    var registrationViewModel: RegistrationViewModel {
        let viewModel = RegistrationViewModel()
        viewModel.delegate = self
        return viewModel
    }
}

// MARK: LoggedInDelegate
extension AppViewModel: LoggedInDelegate {
}
