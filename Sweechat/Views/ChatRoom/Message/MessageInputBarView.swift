import SwiftUI
import os

struct MessageInputBarView: View {
    var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""
    @State private var showingModal = false
    @State private var modalView: ModalView?
    @State private var showingActionSheet = false
    @State private var media: Any?
    @State private var mediaType: MediaType?
    @Binding var messageBeingRepliedTo: MessageViewModel?

    var body: some View {
        VStack {
            if let message = messageBeingRepliedTo {
                HStack {
                    Button(action: { messageBeingRepliedTo = nil }) {
                        // TODO: Make a nicer cancel button
                        Text("X")
                    }
                    Text("\(message.previewContent())")
                }
            }
            HStack {
                TextEditor(text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(5)
                    .frame(idealHeight: 20, maxHeight: 60)
                    .multilineTextAlignment(.leading)
                Button(action: sendTypedMessage) {
                    Image(systemName: "paperplane.fill")
                }
                Button(action: openActionSheet) {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .actionSheet(
            isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Attachment"), message: Text("Select attachment"), buttons: [
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
    func sendTypedMessage() {
        let content = typingMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            return
        }
        viewModel.handleSendMessage(content, withParentId: messageBeingRepliedTo?.id)
        typingMessage = ""
        messageBeingRepliedTo = nil
    }

    private func sendMedia() {
        showingModal = false
        guard let choice = mediaType else {
            os_log("mediaType is nil")
            return
        }

        switch choice {
        case .image:
            viewModel.handleSendImage(media, withParentId: messageBeingRepliedTo?.id)
        case .video:
            viewModel.handleSendVideo(media, withParentId: messageBeingRepliedTo?.id)
        }

        media = nil
        mediaType = nil
        messageBeingRepliedTo = nil
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
