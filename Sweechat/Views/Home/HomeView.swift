import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    @State var isShowingCreateView: Bool = false
    @State var isDirectModuleLoaded = false

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.isDirectModuleLoaded = false
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().backgroundColor = UIColor(ColorConstant.base)
        UINavigationBar.appearance().barTintColor = UIColor(ColorConstant.dark)
        UINavigationBar.appearance().tintColor = UIColor(ColorConstant.dark)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
            GeometryReader { geometry in
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
                                ModuleItemView(viewModel: moduleViewModel, index: index)
                            }
                            .padding()
                        }
                        .padding(.top, 3)
                    }
                    NavigationLink(
                        "",
                        destination: LazyNavView(
                            ModuleView(viewModel: viewModel.directModuleViewModel)
                        ),
                        isActive: Binding<Bool>(
                            get: { viewModel.isDirectModuleLoaded },
                            set: { _ in viewModel.isDirectModuleLoaded = false }
                        )
                    )
                    .hidden()

                    Spacer()
                }
                .frame(width: geometry.size.width)
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
