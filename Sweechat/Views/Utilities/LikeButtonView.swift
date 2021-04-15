import SwiftUI

struct LikeButtonView: View {
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        Button {
            viewModel.toggleLike()
        } label: {
            let countLabel = "\(viewModel.likesCount)"
            let systemImage = viewModel.isCurrentUserLiking ? "hand.thumbsup.fill" : "hand.thumbsup"
            Label(countLabel, systemImage: systemImage)
        }
    }
}

struct LikeButtonView_Previews: PreviewProvider {
    static var shortMessage = "Message being delivered to"

    static var previews: some View {
        LikeButtonView(viewModel: TextMessageViewModel(message: Message(id: "123",
                                                                        senderId: "123",
                                                                        creationTime: Date(),
                                                                        content: shortMessage.toData(),
                                                                        type: MessageType.text,
                                                                        receiverId: "111",
                                                                        parentId: nil, likers: []),
                                                       sender: User(id: "123",
                                                                    name: "Nguyen Chakra Bai"),
                                                       currentUserId: "123"))
    }
}
