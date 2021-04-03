import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            MessageContentViewFactory.makeView(viewModel: viewModel)
            HStack {
                Spacer()
                Text(viewModel.title).font(.footnote)
            }
        }
        .padding(10)
        .border(width: 1, edges: [.bottom], color: .black)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
