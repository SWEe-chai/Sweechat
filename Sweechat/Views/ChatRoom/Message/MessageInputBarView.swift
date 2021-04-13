import SwiftUI
import os

struct MessageInputBarView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    var isShowingParentPreview: Bool
    var allowSendMedia: Bool = true
    @State var typingMessage: String = ""
    @State private var showingModal = false
    @State private var modalView: ModalView?
    @State private var showingActionSheet = false
    @State private var media: Any?
    @State private var mediaType: MediaType?
    @Binding var parentPreviewMetadata: ParentPreviewMetadata?

    var body: some View {
        VStack {
            if let metadata = parentPreviewMetadata,
               isShowingParentPreview {
                HStack {
                    Button(action: { dismissPreview() }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    ParentPreviewView(message: metadata.parentMessage,
                                      borderColor: Color.gray,
                                      isEditPreview: metadata.previewType == .edit)
                        .onTapGesture {
                            // value type semantics. Should update the real one
                            parentPreviewMetadata?.tappedPreview = true
                        }
                }
            }
            HStack {
                TextEditor(text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(5)
                    .frame(idealHeight: 20, maxHeight: 60)
                    .multilineTextAlignment(.leading)
                    .onChange(of: parentPreviewMetadata?.parentMessage) { _ in
                        handleTextEditorChange()
                    }
                Button(action: sendTypedMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(ColorConstant.dark)
                }
                if allowSendMedia {
                    Button(action: openActionSheet) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(ColorConstant.dark)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .actionSheet(
            isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Attachment"), buttons: [
                .default(Text("Image or Video")) { openMediaPicker() },
                .default(Text("Canvas")) { openCanvas() },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingModal, onDismiss: sendMedia) {
            switch modalView {
            case .Canvas:
                CanvasView(showingModal: $showingModal, media: $media, mediaType: $mediaType)
            case .MediaPicker:
                MediaPicker(media: $media, mediaType: $mediaType)
            default:
                EmptyView()
            }
        }
    }

    // TODO: Might want to combine sendTypedMessage with sendMedia. Some common logic
    // like setting messageBeingRepliedTo to nil at the end
    private func sendTypedMessage() {
        let content = typingMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            return
        }
        let parentId = IdentifierConverter.toOptionalMessageId(from: parentPreviewMetadata?.parentMessage.id)
        viewModel.handleSendMessage(content, withParentId: parentId)
        typingMessage = ""
        parentPreviewMetadata = nil
    }

    private func sendMedia() {
        showingModal = false
        guard let choice = mediaType else {
            os_log("mediaType is nil")
            return
        }

        let parentId = IdentifierConverter.toOptionalMessageId(from: parentPreviewMetadata?.parentMessage.id)
        switch choice {
        case .image:
            viewModel.handleSendImage(media, withParentId: parentId)
        case .video:
            viewModel.handleSendVideo(media, withParentId: parentId)
        }

        media = nil
        mediaType = nil
        parentPreviewMetadata = nil
    }

    func openActionSheet() {
        self.showingActionSheet = true
    }

    func openMediaPicker() {
        self.modalView = .MediaPicker
        self.showingModal = true
    }

    func openCanvas() {
        self.modalView = .Canvas
        self.showingModal = true
    }

    private func dismissPreview() {
        guard let parentPreviewMetadata = parentPreviewMetadata else {
            os_log("ParentPreviewMetadata was nil in dismissPreview")
            return
        }

        switch parentPreviewMetadata.previewType {
        case .reply:
            // In this case, you don't want to lose what you have typed
            break
        case .edit:
            // forget about what you wanted to edit the message to
            typingMessage = ""
        }
        self.parentPreviewMetadata = nil
        viewModel.dismissEdit()
    }

    private func handleTextEditorChange() {
        guard let parentPreviewMetadata = parentPreviewMetadata else {
            os_log("ParentPreviewMetadata was nil in handleTextEditorChange")
            return
        }
        switch parentPreviewMetadata.previewType {
        case .edit:
            // NOTE: This only works for text. When you try to edit image, you will see 'Image' instead
            typingMessage = parentPreviewMetadata.parentMessage.previewContent()
        default:
            break
        }
    }
}

struct MessageInputBarView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputBarView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   ownerId: "Me",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ),
            isShowingParentPreview: true,
            parentPreviewMetadata: Binding.constant(nil))
    }
}

// TODO: Currently removed because it is complaining due to the messageBeingRepliedTo
// struct MessageInputBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageInputBarView(
//            viewModel: ChatRoomViewModel(
//                chatRoom: ChatRoom(id: "0",
//                                   name: "CS4269",
//                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
//                                   currentUserPermission: ChatRoomPermission.readWrite),
//                user: User(id: "", name: "Hello", profilePictureUrl: "")
//            ))
//    }
// }
