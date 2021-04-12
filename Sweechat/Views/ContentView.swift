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
            if isFromNotif {
                Text("A")
//                ChatRoomViewFactory
//                    .makeView(
//                        viewModel: appViewModel.loginViewModel
//                            .homeViewModel
//                            .getModuleViewModel(moduleId: directModuleId)
//                            .getChatRoomViewModel(chatRoomId: directChatRoomId)
//
//                        )

            } else {
                Text("B")
                // LoginView(viewModel: appViewModel.loginViewModel)
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
