import Combine
import os

class AppViewModel: ObservableObject {
    var notificationMetadata: NotificationMetadata

    init(notificationMetadata: NotificationMetadata) {
        self.notificationMetadata = notificationMetadata
    }

    var loginViewModel: LoginViewModel {
        LoginViewModel(notificationMetadata: notificationMetadata)
    }

    var registrationViewModel: RegistrationViewModel {
        RegistrationViewModel()
    }
}
