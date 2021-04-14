import SwiftUI

struct CreateModuleView: View {
    @State var moduleName: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Create a Module")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding(.top)
            HStack {
                TextField("Module Name", text: $moduleName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .font(FontConstant.Heading5)
                    .foregroundColor(ColorConstant.medium)
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(ColorConstant.dark)
                    .onTapGesture { tappedCreate() }
            }
            .padding(.top, 7)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(ColorConstant.base)
    }

    func tappedCreate() {
        let name = moduleName.isEmpty ? "Default module name" : moduleName
        viewModel.handleCreateModule(name: name)
        moduleName = ""
    }
}

// struct AddModuleView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateModuleView(viewModel: HomeViewModel(user: User(id: "123")))
//    }
// }
