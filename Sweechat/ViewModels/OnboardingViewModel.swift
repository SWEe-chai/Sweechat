import Foundation

class OnboardingViewModel: ObservableObject {
    weak var delegate: LoggedOutDelegate?

    var text: String {
        "Onboarding"
    }

    func didTapEntryButton() {
        delegate?.navigateToEntry()
    }
}
