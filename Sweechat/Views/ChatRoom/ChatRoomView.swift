import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingCanvas = false
    @State private var showingActionSheet = false

    var inputBar: some View {
        HStack {
            TextEditor(text: $typingMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(5)
                .frame(idealHeight: 20, maxHeight: 60)
                .multilineTextAlignment(.leading)
            Button(action: sendTypedMessage) {
                Text("Send")
            }
            Button(action: openImagePicker) {
                Text("Img")
            }
            Button(action: openCanvas) {
                Text("Canvas")
            }
        }
        .frame(idealHeight: 20, maxHeight: 50)
        .padding()
        .background(Color.gray.opacity(0.1))
        .sheet(isPresented: $showingImagePicker, onDismiss: sendImage) {
            ImagePicker(image: $inputImage)
        }
        .fullScreenCover(isPresented: $showingCanvas, onDismiss: sendImage) {
            CanvasView(showingCanvas: $showingCanvas, inputImage: $inputImage)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Attachment"), message: Text("Select attachment"), buttons: [
                .default(Text("Image")) { openImagePicker() },
                .default(Text("Canvas")) { openCanvas() },
                .cancel()
            ])
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    ForEach(viewModel.messages, id: \.self) {
                        MessageView(viewModel: $0)
                    }
                    .onAppear { scrollToLatestMessage(scrollView) }
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollToLatestMessage(scrollView)
                    }
                    .padding([.leading, .trailing])
                }
            }
            inputBar
        }
        .navigationTitle(Text(viewModel.text))
    }

    func scrollToLatestMessage(_ scrollView: ScrollViewProxy) {
        if viewModel.messages.isEmpty {
            return
        }
        let index = viewModel.messages.count - 1
        scrollView.scrollTo(viewModel.messages[index])

    }

    func sendTypedMessage() {
        let content = typingMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            return
        }
        viewModel.handleSendMessage(content)
        typingMessage = ""
    }

    func openImagePicker() {
        self.showingImagePicker = true
    }

    func sendImage() {
        viewModel.handleSendImage(inputImage)
        inputImage = nil
    }

    func openCanvas() {
        self.showingCanvas = true
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(
            viewModel: ChatRoomViewModel(
                chatRoom: ChatRoom(id: "0", name: "CS4269"),
                user: User(id: "", name: "", profilePictureUrl: "")
            )
        )
    }
}
