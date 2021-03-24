import Combine
import os

class AppViewModel: ObservableObject {
    var loginViewModel: LoginViewModel {
        LoginViewModel()
    }

    var registrationViewModel: RegistrationViewModel {
        RegistrationViewModel()
    }
}
