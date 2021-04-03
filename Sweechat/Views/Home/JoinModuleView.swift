import SwiftUI

struct JoinModuleView: View {
    @State var moduleSecret: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack {
            Text("Join a Module").font(.title2)
            HStack {
                TextField("Module secret", text: $moduleSecret)
                    .padding()
                Button("Join") { tappedCreate() }.padding()
            }
        }
        .padding()
        .background(ColorConstant.base)
    }

    func tappedCreate() {
        viewModel.handleJoinModule(secret: moduleSecret)
        moduleSecret = ""
    }
}

 struct JoinModuleView_Previews: PreviewProvider {
    static var previews: some View {
        JoinModuleView(viewModel: HomeViewModel(user: User(id: "123")))
    }
 }
