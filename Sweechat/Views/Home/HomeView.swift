import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingJoinView: Bool = false

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack {
            if isShowingJoinView {
                JoinModuleView(viewModel: viewModel)
            } else {
                AddModuleView(viewModel: viewModel)
            }
            VStack {
                ForEach(viewModel.moduleViewModels) { moduleViewModel in
                    ModuleItemView(viewModel: moduleViewModel)
                }
            }
            Spacer()
        }
        .background(ColorConstant.base)
        .toolbar {
            HomeToolbarView(
                viewModel: viewModel,
                isShowingJoinView: $isShowingJoinView
            )
        }
        .navigationBarItems(
            leading: Text(viewModel.text)
        )
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: HomeViewModel(
                user: User(id: "8S781SDacTRSBYFQICIHxOS4sin1")
            )
        )
    }
}
