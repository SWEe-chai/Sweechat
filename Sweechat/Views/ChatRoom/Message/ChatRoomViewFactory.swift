import SwiftUI

struct ChatRoomViewFactory {
    static func makeView(viewModel: ChatRoomViewModel) -> some View {
        switch viewModel.permissions {
        case .normal:
            return AnyView(ChatRoomView(viewModel: viewModel))
        case .readOnly:
            // Return some AnnouncementsView here
            return AnyView(AnnouncementView(viewModel: viewModel))
        }
    }
}
