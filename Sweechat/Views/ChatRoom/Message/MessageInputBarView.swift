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

    // var body: some View {
    //     HStack {
    //         TextEditor(text: $typingMessage)
    //             .textFieldStyle(RoundedBorderTextFieldStyle())
    //             .cornerRadius(5)
    //             .frame(idealHeight: 20, maxHeight: 60)
    //             .multilineTextAlignment(.leading)
    //         Button(action: sendTypedMessage) {
    //             Text("Send")
    //         }
    //         Button(action: openMediaPicker) {
    //             Text("Media")
    //         }
    //     }
    //     .frame(idealHeight: 20, maxHeight: 50)
    //     .padding()
    //     .background(Color.gray.opacity(0.1))
    //     .sheet(isPresented: $showingMediaPicker, onDismiss: sendMedia) {
    //         MediaPicker(media: $media, mediaType: $mediaType)
    //     }
    // }
    var body: some View {
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
        .frame(idealHeight: 20, maxHeight: 50)
        .padding()
        .background(Color.gray.opacity(0.1))
        .actionSheet(
            isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Attachment"), message: Text("Select attachment"), buttons: [
                .default(Text("Image")) { openImagePicker() },
                .default(Text("Canvas")) { openCanvas() },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingModal, onDismiss: sendMedia) {
            switch modalView {
            case .Canvas:
                CanvasView(showingModal: $showingModal, media: $media, mediaType: $mediaType)
            case .ImagePicker:
                MediaPicker(media: $media, mediaType: $mediaType)
            default:
                EmptyView()
            }
        }
    }

    func sendTypedMessage() {
        let content = typingMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            return
        }
        viewModel.handleSendMessage(content)
        typingMessage = ""
    }

    // func openMediaPicker() {
    //     self.showingMediaPicker = true
    // }

    private func sendMedia() {
        guard let choice = mediaType else {
            os_log("mediaType is nil")
            return
        }

        switch choice {
        case .image:
            viewModel.handleSendImage(media)
        case .video:
            viewModel.handleSendVideo(media)
        }

        media = nil
        mediaType = nil
    }

    func openActionSheet() {
        self.showingActionSheet = true
    }

    func openImagePicker() {
        self.showingModal = true
        self.modalView = .ImagePicker
    }

    func openCanvas() {
        self.showingModal = true
        self.modalView = .Canvas
    }

    // func sendImage() {
    //     self.showingModal = false
    //     viewModel.handleSendImage(inputImage)
    //     inputImage = nil
    // }

}

struct MessageInputBarView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputBarView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0",
                                   name: "CS4269",
                                   currentUser: User(id: "", name: "Hello", profilePictureUrl: ""),
                                   currentUserPermission: ChatRoomPermission.readWrite),
                user: User(id: "", name: "Hello", profilePictureUrl: "")
            ))
    }
}
