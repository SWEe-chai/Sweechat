import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            EntryView(viewModel: appViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
