import SwiftUI

struct ModuleInformation: View {
    @ObservedObject var viewModel: ModuleViewModel
    @State var copied: Bool = false
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Module secret")
                    .font(FontConstant.Heading1)
                    .foregroundColor(ColorConstant.dark)
                    .padding(.top)
                Text("* Other users can join this module by entering this Module secret")
                    .font(FontConstant.Heading5)
                    .foregroundColor(ColorConstant.medium)
                Text("* Press and hold the secret to copy to clipboard:")
                    .font(FontConstant.Heading5)
                    .foregroundColor(ColorConstant.medium)

                Text("\(viewModel.id)")
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(white: 0, opacity: 0.5), lineWidth: 1)
                    )
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(white: 0, opacity: 0.5), lineWidth: 1))
                    .padding(.trailing)
                Text("Hello World")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.purple)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.purple, lineWidth: 5)
                    )

    //            Text("\(viewModel.id)")
    //                .font(.title3)
    //                .padding()
    //                .onLongPressGesture(minimumDuration: 0.5) {
    //                    UIPasteboard.general.string = viewModel.id
    //                    copied = true
    //                }
                if copied {
                    Text("Module Secret has been copied to clipboard!").font(.caption)
                }
            }
            Spacer()
        }
        .background(ColorConstant.base)
        .onAppear { isNavigationBarHidden = false }
        .navigationBarHidden(isNavigationBarHidden)
        .navigationTitle(viewModel.text)
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
