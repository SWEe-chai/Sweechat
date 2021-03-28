import SwiftUI

struct TextMessageContentView: View {
    @ObservedObject var viewModel: MessageViewModel
    var body: some View {
        if let content = viewModel.content {
            Text(content)
        }
    }
}
