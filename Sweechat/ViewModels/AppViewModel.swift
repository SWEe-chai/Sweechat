import Foundation

class AppViewModel: ObservableObject {
    @Published var state: AppState
    
    init() {
        state = AppState.onboarding
    }

    var onboardingViewModel: OnboardingViewModel {
        OnboardingViewModel()
    }
}
