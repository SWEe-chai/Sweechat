import SwiftUI

struct MostPopularThreadMessageView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundColor(ColorConstant.light)

                MessageContentViewFactory.makeView(viewModel: viewModel)
                    .foregroundColor(ColorConstant.light)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(ColorConstant.light)
            }
        }
        .padding(10)
//        .background(ColorConstant.light)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}
