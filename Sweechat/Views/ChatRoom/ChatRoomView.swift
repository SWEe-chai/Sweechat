import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var parentPreviewMetadata: ParentPreviewMetadata?

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel,
                               parentPreviewMetadata: $parentPreviewMetadata)
            MessageInputBarView(viewModel: viewModel,
                                isShowingParentPreview: true,
                                parentPreviewMetadata: $parentPreviewMetadata)
        }
        .background(ColorConstant.base)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .navigationTitle(Text(viewModel.text))
    }

}

struct ParentPreviewMetadata {
    var parentMessage: MessageViewModel
    var tappedPreview: Bool = false
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   ownerId: "Me",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            )
        )
    }
}

enum ModalView {
    case MediaPicker
    case Canvas
}
