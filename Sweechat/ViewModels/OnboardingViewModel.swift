import Foundation

class OnboardingViewModel: ObservableObject {
    var delegate: OnboardingDelegate?

    var text: String {
        "Onboarding"
    }

    func didTapEntryButton() {
        delegate?.navigateToEntry()
    }
}
