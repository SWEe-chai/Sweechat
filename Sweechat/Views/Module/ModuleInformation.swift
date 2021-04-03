import SwiftUI

struct ModuleInformation: View {
    @ObservedObject var viewModel: ModuleViewModel
    var body: some View {
        VStack {
            Text(viewModel.text).font(.title)
            Divider().padding()
            Text("Module secret:").font(.callout)
            Text("Other users can join this module by entering this Module secret").font(.caption)
            Text("\(viewModel.id)").font(.title3).padding()
        }.navigationTitle("Module Information")
    }
}

struct ModuleInformation_Previews: PreviewProvider {
    static var previews: some View {
        ModuleInformation(
            viewModel:
                ModuleViewModel(
                    module: Module(id: "1", name: "Name", currentUser: User(id: "1")),
                    user: User(id: "2", name: "Name")))
    }
}
