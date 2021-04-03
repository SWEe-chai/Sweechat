import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if viewModel.isRightAlign { Spacer() }
            VStack(alignment: .leading) {
                if let title = viewModel.title {
                    Text(title).font(.footnote)
                }
                VStack(alignment: .leading) {
                    MessageContentViewFactory.makeView(viewModel: viewModel)
                }
                .padding(10)
                .foregroundColor(viewModel.foregroundColor)
                .background(viewModel.backgroundColor)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
