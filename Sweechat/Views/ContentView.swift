import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        switch appViewModel.state {
        case AppState.onboarding:
            OnboardingView(onboardingViewModel: appViewModel.onboardingViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
