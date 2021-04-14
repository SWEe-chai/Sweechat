import SwiftUI

struct ThreadView: View {
    @ObservedObject var viewModel: ThreadChatRoomViewModel
    @State var parentPreviewMetadata: ParentPreviewMetadata?
    var body: some View {
        VStack {
            ForumPostView(viewModel: viewModel.post).padding()
            MessagesScrollView(viewModel: viewModel,
                               parentPreviewMetadata: $parentPreviewMetadata)
            MessageInputBarView(viewModel: viewModel,
                                isShowingParentPreview: true,
                                parentPreviewMetadata: $parentPreviewMetadata)
        }.background(ColorConstant.base)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .navigationTitle(Text("Thread"))
    }
}
