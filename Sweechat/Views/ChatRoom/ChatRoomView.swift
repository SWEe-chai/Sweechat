import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State var typingMessage: String = ""
    @State private var inputImage: UIImage?
    @State private var showingModal = false
    @State private var modalView: ModalView?
    @State private var showingActionSheet = false

    var inputBar: some View {
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
        .sheet(isPresented: $showingModal, onDismiss: sendImage) {
            switch modalView {
            case .Canvas:
            CanvasView(showingModal: $showingModal, inputImage: $inputImage)
            case .ImagePicker:
                ImagePicker(image: $inputImage)
            default:
                EmptyView()
            }
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

    func sendImage() {
        self.showingModal = false
        viewModel.handleSendImage(inputImage)
        inputImage = nil
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

enum ModalView {
    case ImagePicker
    case Canvas
}
