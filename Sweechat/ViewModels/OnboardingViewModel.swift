import Foundation

class OnboardingViewModel: ObservableObject {
    weak var delegate: OnboardingDelegate?

    var text: String {
        "Onboarding"
    }

    func didTapEntryButton() {
        delegate?.navigateToEntry()
    }
}
