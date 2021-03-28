import SwiftUI

struct AddModuleView: View {
    @Binding var isShowing: Bool
    @State var moduleName: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack {
            Text("Create a Module").font(.title2)
            TextField("Module name", text: $moduleName).padding()
            HStack {
                Button("Cancel") { close() }.padding()
                Button("Create") { tappedCreate() }.padding()
            }
        }
        .padding()
        .background(Color.white)
    }

    func tappedCreate() {
        let name = moduleName.isEmpty ? "Default module name" : moduleName
        viewModel.handleCreateModule(name: name)
        moduleName = ""
        close()
    }

    func close() {
        moduleName = ""
        isShowing = false
    }
}

struct AddModuleView_Previews: PreviewProvider {
    static var previews: some View {
        AddModuleView(isShowing: .constant(true),
                      viewModel: HomeViewModel(user: User(id: "123")))
    }
}
