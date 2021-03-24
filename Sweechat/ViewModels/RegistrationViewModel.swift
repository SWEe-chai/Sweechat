import Foundation

class RegistrationViewModel: ObservableObject {
    weak var delegate: LoggedInDelegate?

    var text: String {
        "Registration"
    }
}
