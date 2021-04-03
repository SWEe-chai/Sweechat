import SwiftUI

struct JoinModuleView: View {
//    @Binding var isShowing: Bool
    @State var moduleSecret: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack {
            Text("Join a Module").font(.title2)
            TextField("Module secret", text: $moduleSecret).padding()
            HStack {
//                Button("Cancel") { close() }.padding()
                Button("Join") { tappedCreate() }.padding()
            }
        }
        .padding()
        .background(ColorConstant.base)
    }

    func tappedCreate() {
        viewModel.handleJoinModule(secret: moduleSecret)
        moduleSecret = ""
        close()
    }

    func close() {
        moduleSecret = ""
//        isShowing = false
    }
}

// struct JoinModuleView_Previews: PreviewProvider {
//    static var previews: some View {
//        JoinModuleView(isShowing: .constant(true),
//                       viewModel: HomeViewModel(user: User(id: "123")))
//    }
// }
