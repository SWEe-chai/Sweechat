import SwiftUI

struct ImageMessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                if let title = viewModel.title {
                    Text(title).font(.footnote)
                }
                if let content = viewModel.content {
                    RemoteImage(url: content)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding(10)
                        .foregroundColor(viewModel.foregroundColor)
                        .background(viewModel.backgroundColor)
                        .cornerRadius(10)
                }
            }
            if !viewModel.isRightAlign { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
}
