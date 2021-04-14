import SwiftUI

struct ModuleInformation: View {
    @ObservedObject var viewModel: ModuleViewModel
    @State var copied: Bool = false

    var body: some View {
        VStack {
            Text(viewModel.text).font(.title)
            Divider().padding()
            Text("Module secret:").font(.callout)
            Text("Other users can join this module by entering this Module secret").font(.caption)
            Text("Press and hold the secret to copy to clipboard:").font(.caption)
            Text("\(viewModel.id)")
                .font(.title3)
                .padding()
                .onLongPressGesture(minimumDuration: 0.5) {
                    UIPasteboard.general.string = viewModel.id
                    copied = true
                }
            if copied {
                Text("Module Secret has been copied to clipboard!").font(.caption)
            }
        }
        .navigationBarHidden(false)
        .navigationTitle("Module Information")
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
                    user: User(id: "2", name: "Name"),
                    notificationMetadata: NotificationMetadata()
                )
        )
    }
}
