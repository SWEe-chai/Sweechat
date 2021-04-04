import SwiftUI

struct CreateModuleView: View {
    @State var moduleName: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a Module")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.font1)
            HStack {
                TextField("Module name", text: $moduleName).padding()
                Button("Create") { tappedCreate() }.padding()
            }
        }
        .padding()
        .background(ColorConstant.base)
    }

    func tappedCreate() {
        let name = moduleName.isEmpty ? "Default module name" : moduleName
        viewModel.handleCreateModule(name: name)
        moduleName = ""
    }
}

 struct AddModuleView_Previews: PreviewProvider {
    static var previews: some View {
        CreateModuleView(viewModel: HomeViewModel(user: User(id: "123")))
    }
 }
