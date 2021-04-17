import SwiftUI

struct ForumChatRoomView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    @State var parentPreviewMetadata: ParentPreviewMetadata?
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        VStack {
            ForumPostsView(viewModel: viewModel)
            MessageInputBarView(sendMessageHandler: viewModel,
                                isShowingParentPreview: false,
                                allowSendMedia: false,
                                parentPreviewMetadata: $parentPreviewMetadata)
        }
        .onAppear {
            isNavigationBarHidden = false
        }
        .navigationTitle(viewModel.text)
    }
}
