import Combine
import os

class AppViewModel: ObservableObject {
    @Published var isFromNotif: Bool = false
    @Published var directChatRoomId: String = ""
    @Published var directModuleId: String = ""

    var loginViewModel: LoginViewModel {
        LoginViewModel()
    }

    var registrationViewModel: RegistrationViewModel {
        RegistrationViewModel()
    }
}
