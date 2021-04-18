import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingCreateView: Bool = false

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().backgroundColor = UIColor(ColorConstant.base)
        UINavigationBar.appearance().tintColor = UIColor(ColorConstant.dark)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack {
            if isShowingCreateView {
                CreateModuleView(viewModel: viewModel)
            } else {
                JoinModuleView(viewModel: viewModel)
            }
            VStack(alignment: .leading, spacing: 0) {
                if !viewModel.moduleViewModels.isEmpty {
                    Text("Modules")
                        .font(FontConstant.Heading1)
                        .foregroundColor(ColorConstant.dark)
                        .padding(.horizontal)
                }
                ScrollView(showsIndicators: false) {
                    ForEach(
                        Array(
                            viewModel.moduleViewModels.enumerated()), id: \.offset) { index, moduleViewModel in
                        Button(action: {
                            viewModel.directModuleViewModel = moduleViewModel
                            viewModel.isDirectModuleLoaded = true
                        }) {
                            ModuleItemView(viewModel: moduleViewModel, index: index)
                        }
                    }
                    .padding()
                    NavigationLink(
                        "",
                        destination: LazyNavView(
                            ModuleView(viewModel: viewModel.directModuleViewModel)),
                        isActive: $viewModel.isDirectModuleLoaded
                    )
                }
                .padding(.top, 3)
            }
            Spacer()
        }
        .background(ColorConstant.base)
        .toolbar {
            HomeToolbarView(
                viewModel: viewModel,
                isShowingCreateView: $isShowingCreateView
            )
        }
        .navigationBarItems(
            leading: Text(viewModel.text)
                .foregroundColor(ColorConstant.dark)
        )
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: HomeViewModel(
                user: User(id: "8S781SDacTRSBYFQICIHxOS4sin1"),
                notificationMetadata: NotificationMetadata()
            )
        )
    }
}
