import SwiftUI

struct StarTickBoxView: View {
    @ObservedObject var viewModel: CreateChatRoomViewModel

    var body: some View {
        if viewModel.canStar {
            Text("Tip: Star chat rooms that will be used for official module communication")
                .font(FontConstant.ModuleDescription)
                .foregroundColor(ColorConstant.dark)
                .padding(.bottom)
            TickableItem(
                isLit: $viewModel.isStarred,
                onTap: { viewModel.isStarred.toggle() },
                text: "Star Chat Room")
        }
    }
}
