import SwiftUI

struct ImageMessageContentView: View {
    @ObservedObject var viewModel: MessageViewModel
    var body: some View {
        if let content = viewModel.content {
            RemoteImage(url: content)
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
    }
}
