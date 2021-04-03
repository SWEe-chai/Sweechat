import SwiftUI

struct ForumPostView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            MessageContentViewFactory.makeView(viewModel: viewModel)
            HStack {
                Spacer()
                Text(viewModel.senderName).font(.footnote)
            }
        }
        .padding(10)
        .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.1))
        .border(width: 1,
                edges: [.bottom],
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.5))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
