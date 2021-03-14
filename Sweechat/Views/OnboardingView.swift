import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboardingViewModel: OnboardingViewModel

    var body: some View {
        Text(onboardingViewModel.text)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onboardingViewModel: OnboardingViewModel())
    }
}
