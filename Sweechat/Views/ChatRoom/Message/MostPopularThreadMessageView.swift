import SwiftUI

struct MostPopularThreadMessageView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image(systemName: "star.fill")
                }
                MessageContentViewFactory.makeView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding(10)
        .background(ColorConstant.light)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
