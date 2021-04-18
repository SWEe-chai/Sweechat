import SwiftUI

struct MostPopularThreadMessageView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(ColorConstant.primary)

                MessageContentViewFactory.makeView(viewModel: viewModel)
                    .foregroundColor(ColorConstant.primary)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(ColorConstant.primary)
            }
        }
        .padding(10)
//        .background(ColorConstant.light)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
