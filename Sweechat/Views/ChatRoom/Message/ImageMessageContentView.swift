import SwiftUI

struct ImageMessageContentView: View {
    @ObservedObject var viewModel: ImageMessageViewModel
    var body: some View {
        RemoteImage(url: viewModel.url)
            .aspectRatio(contentMode: .fit)
            .frame(width: 200)
    }
}
