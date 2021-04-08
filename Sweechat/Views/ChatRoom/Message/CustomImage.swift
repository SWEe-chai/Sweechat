import SwiftUI

struct CustomImage: View {
    @ObservedObject var viewModel: MediaDataViewModel

    var failureImage: Image {
        Image(systemName: "multiply.circle")
    }

    var loadingImage: Image {
        Image(systemName: "photo")
    }

    func selectedImage() -> Image {
        switch viewModel.state {
        case .loading:
            return loadingImage
        case .failed:
            return failureImage
        case .success:
            if let image = UIImage(data: viewModel.data) {
                return Image(uiImage: image)
            } else {
                return failureImage
            }
        }
    }

    var body: some View {
        selectedImage().resizable()
    }
}
