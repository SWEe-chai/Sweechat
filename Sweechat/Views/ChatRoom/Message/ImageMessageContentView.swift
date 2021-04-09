import SwiftUI

struct ImageMessageContentView: View {
    @ObservedObject var viewModel: ImageMessageViewModel
    var body: some View {
        CustomImage(viewModel: viewModel.mediaData)
            .scaledToFit()
            .frame(width: 200)
    }
}
