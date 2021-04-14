import SwiftUI

struct MostPopularThreadMessageView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "star.fill")
            MessageContentViewFactory.makeView(viewModel: viewModel)
        }
        .padding(10)
        .background(ColorConstant.light)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
