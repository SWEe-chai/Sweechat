import SwiftUI

struct ChatRoomViewFactory {
    static func makeView(viewModel: ChatRoomViewModel) -> some View {
        switch viewModel.permissions {
        case .normal:
            // return DrawingView()
            return ChatRoomView(viewModel: viewModel)
        case .readOnly:
            // Return some AnnouncementsView here
            return ChatRoomView(viewModel: viewModel)
        }
    }
}
