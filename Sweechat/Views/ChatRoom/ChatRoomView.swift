import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @Binding var isNavigationBarHidden: Bool
    @State var parentPreviewMetadata: ParentPreviewMetadata?

    var body: some View {
        VStack {
            MessagesScrollView(viewModel: viewModel,
                               parentPreviewMetadata: $parentPreviewMetadata)
            MessageInputBarView(sendMessageHandler: viewModel,
                                isShowingParentPreview: true,
                                parentPreviewMetadata: $parentPreviewMetadata)
        }
        .onAppear {
            viewModel.handleChatRoomAppearance()
            isNavigationBarHidden = false
        }
        .navigationBarHidden(isNavigationBarHidden)
        .background(ColorConstant.base)
        .navigationTitle(Text(viewModel.text))
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   ownerId: "Me",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite,
                                   isStarred: false),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ), isNavigationBarHidden: Binding<Bool>(
                get: { true },
                set: { _ in }
            )
        )
    }
}

enum ModalView {
    case MediaPicker
    case Canvas
}
