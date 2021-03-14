import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        switch appViewModel.state {
        case AppState.entry:
            EntryView(viewModel: appViewModel.entryViewModel)
        case AppState.onboarding:
            OnboardingView(viewModel: appViewModel.onboardingViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
