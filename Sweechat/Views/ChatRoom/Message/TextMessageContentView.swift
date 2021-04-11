import SwiftUI

struct TextMessageContentView: View {
    @ObservedObject var viewModel: TextMessageViewModel

    var body: some View {
        Text(viewModel.text)
    }
}
