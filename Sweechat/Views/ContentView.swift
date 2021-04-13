import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            if appViewModel.isFromNotif {
//                ChatRoomViewFactory
//                    .makeView(
//                        viewModel: appViewModel.loginViewModel
//                            .homeViewModel
//                            .getModuleViewModel(moduleId: appViewModel.directModuleId)
//                            .getChatRoomViewModel(chatRoomId: appViewModel.directChatRoomId)
//
//                        )
                SettingsView(viewModel: appViewModel.loginViewModel.homeViewModel.settingsViewModel)
            } else {
                 LoginView(viewModel: appViewModel.loginViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
