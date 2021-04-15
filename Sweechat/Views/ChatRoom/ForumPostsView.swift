import SwiftUI
import os

struct ForumPostsView: View {
    @ObservedObject var viewModel: ForumChatRoomViewModel
    @State var isThreadOpen: Bool = false
    var body: some View {
        VStack {
            ScrollView {
                if !viewModel.areAllMessagesLoaded {
                    Button(action: viewModel.loadMore) { Text("older messages...") }.padding()
                }
                ForEach(viewModel.threads, id: \.self) { threadChatRoomViewModel in
                    ForumPostView(viewModel: threadChatRoomViewModel)
                        .onTapGesture(count: 1) {
                            viewModel.setThread(threadChatRoomViewModel.post)
                            isThreadOpen = true
                        }
                }
                .padding([.leading, .trailing])
            }
            NavigationLink(
                "",
                destination: LazyNavView(
                    ThreadView(viewModel: viewModel.getSelectedThread())),
                isActive: $isThreadOpen
            ).hidden()
        }
    }
}
