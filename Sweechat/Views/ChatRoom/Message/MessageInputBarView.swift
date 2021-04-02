import SwiftUI
import os

struct MessageInputBarView: View {
    var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""
    @State private var showingMediaPicker = false
    @State private var pickedMedia: Any?
    @State private var pickedMediaType: PickedMediaType?
    @Binding var messageBeingRepliedTo: MessageViewModel?

    var body: some View {
        if let message = messageBeingRepliedTo {
            HStack {
                Button(action: { messageBeingRepliedTo = nil }) {
                    // TODO: Make a nicer cancel button
                    Text("X")
                }
                Text("Replying to message with id: \(message.id)")
            }
        }
        VStack {
            HStack {
                TextEditor(text: $typingMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(5)
                    .frame(idealHeight: 20, maxHeight: 60)
                    .multilineTextAlignment(.leading)
                Button(action: sendTypedMessage) {
                    Text("Send")
                }
                Button(action: openMediaPicker) {
                    Text("Media")
                }
            }
            .frame(idealHeight: 20, maxHeight: 50)
            .padding()
            .background(Color.gray.opacity(0.1))
            .sheet(isPresented: $showingMediaPicker, onDismiss: sendMedia) {
                MediaPicker(pickedMedia: $pickedMedia, pickedMediaType: $pickedMediaType)
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

    func openMediaPicker() {
        self.showingMediaPicker = true
    }

    private func sendMedia() {
        guard let choice = pickedMediaType else {
            os_log("pickedMediaType is nil")
            return
        }

        switch choice {
        case .image:
            viewModel.handleSendImage(pickedMedia)
        case .video:
            viewModel.handleSendVideo(pickedMedia)
        }

        pickedMedia = nil
        pickedMediaType = nil
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
