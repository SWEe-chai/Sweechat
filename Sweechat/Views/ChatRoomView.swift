import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel

    var body: some View {
        Text(viewModel.text)
    }
}
