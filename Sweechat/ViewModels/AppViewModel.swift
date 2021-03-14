import Foundation

class AppViewModel: ObservableObject {
    @Published var state: AppState

    init() {
        state = AppState.onboarding
    }

    var entryViewModel: EntryViewModel {
        EntryViewModel()
    }

    var onboardingViewModel: OnboardingViewModel {
        let viewModel = OnboardingViewModel()
        viewModel.delegate = self
        return viewModel
    }

    private func change(state: AppState) {
        self.state = state
    }
}

extension AppViewModel: OnboardingDelegate {
    func navigateToEntry() {
        change(state: AppState.entry)
    }
}
