import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingJoinView: Bool = false
    @State var isShowingAddView: Bool = false

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            ColorConstant.base.ignoresSafeArea()

            VStack {
                ForEach(viewModel.moduleViewModels) { moduleViewModel in
                    ModuleItemView(viewModel: moduleViewModel)
                }
            }
            if isShowingAddView {
                AddModuleView(
                    isShowing: $isShowingAddView,
                    viewModel: viewModel
                )
            }
            if isShowingJoinView {
                JoinModuleView(
                    isShowing: $isShowingJoinView,
                    viewModel: viewModel
                )
            }
        }
        .background(ColorConstant.base)
        .toolbar {
            HomeToolbarView(
                viewModel: viewModel,
                isShowingJoinView: $isShowingJoinView,
                isShowingAddView: $isShowingAddView
            )
        }
        .navigationBarItems(
            leading: Text(viewModel.text)
                .foregroundColor(ColorConstant.font2)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .padding()
                .frame(maxWidth: .infinity)
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
