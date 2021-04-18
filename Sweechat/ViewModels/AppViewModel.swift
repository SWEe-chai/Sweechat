import Combine

class AppViewModel: ObservableObject {
    let notificationMetadata: NotificationMetadata

    var loginViewModel: LoginViewModel {
        LoginViewModel(notificationMetadata: notificationMetadata)
    }

    var registrationViewModel: RegistrationViewModel {
        RegistrationViewModel()
    }

    // MARK: Initialization

    init(notificationMetadata: NotificationMetadata) {
        self.notificationMetadata = notificationMetadata
    }
}
