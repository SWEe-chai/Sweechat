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
                CreateModuleView(viewModel: viewModel)
            }
            VStack(alignment: .leading) {
                Text("Modules")
                    .font(FontConstant.Heading1)
                    .foregroundColor(ColorConstant.font1)

                ForEach(viewModel.moduleViewModels) { moduleViewModel in
                    ModuleItemView(viewModel: moduleViewModel)
                }
            }
            .padding()
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
                .foregroundColor(ColorConstant.font1)
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
