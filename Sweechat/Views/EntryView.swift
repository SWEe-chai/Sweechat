import SwiftUI

struct EntryView: View {
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        Text(viewModel.text)
    }
}
