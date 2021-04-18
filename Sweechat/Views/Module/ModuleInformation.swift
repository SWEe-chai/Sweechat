import SwiftUI

struct ModuleInformation: View {
    @ObservedObject var viewModel: ModuleViewModel
    @State var copied: Bool = false
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Module secret")
                    .font(FontConstant.Heading1)
                    .foregroundColor(ColorConstant.dark)
                    .padding(.top)
                    .padding(.bottom, 3)

                Text("● Other users can join this module by entering this Module secret")
                    .font(FontConstant.Heading5)
                    .foregroundColor(ColorConstant.medium)

                HStack(alignment: .center) {
                    Text("● Press and hold the secret to copy to clipboard:")
                        .font(FontConstant.Heading5)
                        .foregroundColor(ColorConstant.medium)
                }
                moduleSecret
                if copied {
                    Text("Module Secret has been copied to clipboard!").font(FontConstant.Description)
                }

                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 3)
        .background(ColorConstant.base)
        .onAppear { isNavigationBarHidden = false }
        .navigationBarHidden(isNavigationBarHidden)
        .navigationTitle(viewModel.text)
    }
    
    var moduleSecret: some View {
        Text("\(viewModel.id)")
            .font(FontConstant.Heading4)
            .foregroundColor(ColorConstant.medium)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorConstant.light)
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                UIPasteboard.general.string = viewModel.id
                copied = true
            }
    }
}

struct ModuleInformation_Previews: PreviewProvider {
    static var previews: some View {
        ModuleInformation(
            viewModel:
                ModuleViewModel(
                    module: Module(
                        id: "1",
                        name: "Name",
                        currentUser: User(id: "1"),
                        currentUserPermission: ModulePermission.moduleOwner
                    ),
                    user: User(id: "2", name: "Name")
                ), isNavigationBarHidden: .constant(false)
        )
    }
}
